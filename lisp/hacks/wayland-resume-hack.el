;;; wayland-resume-hack.el --- Hack for PGTK blur after resume -*- lexical-binding: t; -*-

;; This module intentionally depends on functions/variables defined in
;; early-init.el:
;; - m/monitor-attributes
;; - m/frame-scale
;; - m/monitor-font-size-cache
;; - set-dynamic-font

(defvar m/frame-display-signatures (make-hash-table :test #'eq)
  "Cache display signatures keyed by frame object.")

(defvar m/aggressive-wayland-resume-recovery t
  "If non-nil, run configured recovery after resume on standalone PGTK Emacs.
This is a pragmatic hack for blur/scale glitches after sleep.")

(defvar m/prepare-for-sleep-dbus-handle nil
  "DBus registration handle for login1 PrepareForSleep signal.")

(defvar m/wayland-resume-recovery-method 'replace-frame
  "Method used to recover from Wayland blur after resume.
Supported values are `replace-frame' and `nudge'.")

(defvar m/recovery-pending-after-resume nil
  "Whether a post-resume Wayland recovery should still be attempted.")

(defvar m/recovery-focus-timer nil
  "Debounce timer for focus-triggered resume recovery.")

(defun m/frame-display-signature (&optional frame)
  "Return display signature for FRAME."
  (let* ((attrs (m/monitor-attributes frame))
         (name (cdr-safe (assq 'name attrs)))
         (geometry (cdr-safe (assq 'geometry attrs)))
         (mm-size (cdr-safe (assq 'mm-size attrs)))
         (scale-factor (cdr-safe (assq 'scale-factor attrs))))
    (list name geometry mm-size scale-factor (m/frame-scale frame))))

(defun m/refresh-frame-display-state (&optional frame force)
  "Refresh FRAME display state after monitor/scale changes.
If FORCE is non-nil, refresh even when signature appears unchanged."
  (let ((target (or frame (selected-frame))))
    (when (and target (frame-live-p target) (display-graphic-p target))
      (let* ((signature (m/frame-display-signature target))
             (cached-signature (gethash target m/frame-display-signatures)))
        (when (or force (not (equal signature cached-signature)))
          (puthash target signature m/frame-display-signatures)
          ;; Suspend/resume can keep stale values around briefly.
          (clrhash m/monitor-font-size-cache)
          (set-dynamic-font target)
          (redraw-frame target)
          (force-window-update (frame-root-window target)))))))

(defun m/nudge-wayland-surfaces ()
  "Create and remove a temporary frame to force fresh Wayland surfaces."
  (interactive)
  (when (and (featurep 'pgtk) (not (daemonp)))
    (let* ((origin (selected-frame))
           (temp (make-frame '((name . "emacs-resume-nudge")
                               (minibuffer . nil)
                               (width . 20)
                               (height . 6)))))
      (when (frame-live-p origin)
        (select-frame-set-input-focus origin))
      ;; Keep the frame around briefly so the compositor performs full commit.
      (run-at-time 0.25 nil
                   (lambda (frame origin-frame)
                     (when (frame-live-p frame)
                       (delete-frame frame t))
                     (when (frame-live-p origin-frame)
                       (select-frame-set-input-focus origin-frame)
                       (m/refresh-frame-display-state origin-frame t)))
                   temp origin)
      t)))

(defun m/replace-selected-frame ()
  "Replace selected GUI frame with a newly created one, preserving window state."
  (interactive)
  (let ((frame (selected-frame)))
    (when (and (frame-live-p frame) (display-graphic-p frame))
      (condition-case nil
          (let* ((state (window-state-get (frame-root-window frame) t))
                 (params (frame-parameters frame))
                 (keep '(left top width height fullscreen undecorated
                              internal-border-width alpha background-color
                              font))
                 (new-params
                  (delq nil
                        (mapcar (lambda (key)
                                  (let ((cell (assq key params)))
                                    (and cell (cons key (cdr cell)))))
                                keep)))
                 (new-frame (make-frame new-params)))
            (with-selected-frame new-frame
              (ignore-errors
                (window-state-put state (frame-root-window new-frame) 'safe))
              (m/refresh-frame-display-state new-frame t))
            (select-frame-set-input-focus new-frame)
            (delete-frame frame t)
            t)
        (error nil)))))

(defun m/recover-wayland-after-resume ()
  "Apply configured Wayland resume recovery method."
  (interactive)
  (let ((ok (pcase m/wayland-resume-recovery-method
              ('nudge (m/nudge-wayland-surfaces))
              (_ (m/replace-selected-frame)))))
    (when ok
      (setq m/recovery-pending-after-resume nil))
    ok))

(defun m/run-pending-resume-recovery ()
  "Run pending Wayland resume recovery if still needed."
  (setq m/recovery-focus-timer nil)
  (when m/recovery-pending-after-resume
    (m/recover-wayland-after-resume)))

(defun m/schedule-pending-resume-recovery ()
  "Schedule pending resume recovery once focus has returned."
  (when (and m/recovery-pending-after-resume
             (not (timerp m/recovery-focus-timer)))
    (setq m/recovery-focus-timer
          (run-at-time 0.20 nil #'m/run-pending-resume-recovery))))

(defun m/forget-frame-display-state (frame)
  "Forget cached display signature for FRAME."
  (remhash frame m/frame-display-signatures))

(defun m/on-focus-in ()
  "Refresh selected frame when focus returns."
  (m/schedule-pending-resume-recovery))

(defun m/handle-prepare-for-sleep (&rest args)
  "Handle PrepareForSleep DBus signal.
Some setups pass only the boolean, others include extra metadata."
  (let ((sleeping (car (last args))))
    (unless sleeping
      (when (and m/aggressive-wayland-resume-recovery
                 (featurep 'pgtk)
                 (not (daemonp)))
        (setq m/recovery-pending-after-resume t)
        (when (timerp m/recovery-focus-timer)
          (cancel-timer m/recovery-focus-timer)
          (setq m/recovery-focus-timer nil))
        ;; Retry because compositor/output state can settle in phases post-resume.
        (run-at-time 1.4 nil #'m/run-pending-resume-recovery)
        (run-at-time 2.6 nil #'m/run-pending-resume-recovery)))))

(defun m/install-resume-refresh-hook ()
  "Install logind DBus resume refresh hook when available."
  (when (and (eq system-type 'gnu/linux)
             (require 'dbus nil t))
    (when m/prepare-for-sleep-dbus-handle
      (ignore-errors
        (dbus-unregister-object m/prepare-for-sleep-dbus-handle)))
    (ignore-errors
      (setq m/prepare-for-sleep-dbus-handle
            (dbus-register-signal
             :system
             "org.freedesktop.login1"
             "/org/freedesktop/login1"
             "org.freedesktop.login1.Manager"
             "PrepareForSleep"
             #'m/handle-prepare-for-sleep)))))

;; Resume-only hook: avoid startup redraw hooks that can cause gray flashes.
(add-hook 'focus-in-hook #'m/on-focus-in)
(add-hook 'delete-frame-functions #'m/forget-frame-display-state)

(m/install-resume-refresh-hook)

(provide 'wayland-resume-hack)

;;; wayland-resume-hack.el ends here
