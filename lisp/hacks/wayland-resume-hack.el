;;; wayland-resume-hack.el --- Hack for PGTK blur after resume -*- lexical-binding: t; -*-

;; This module intentionally depends on functions/variables defined in
;; early-init.el:
;; - m/monitor-attributes
;; - m/frame-scale
;; - m/monitor-font-size-cache
;; - set-dynamic-font

;; Why this hack exists — analysis as of 2026-05 (Emacs 30.2 PGTK,
;; GTK 3.24.52, Hyprland 0.55.2, Arch/Omarchy, eDP-1 2880x1800 @ scale 2):
;;
;; Symptom: after suspend/resume (or DPMS off/on), PGTK frames render
;; blurry on scaled Wayland outputs until their wl_surface is recreated.
;;
;; Root cause is Hyprland <-> GTK3 interaction, not Emacs:
;;
;; - On Wayland, a window's buffer scale is decided inside GDK:
;;   gdkwindow-wayland.c:window_update_scale() takes the max scale of
;;   the wl_outputs the surface has *entered*, driven entirely by
;;   compositor-sent wl_surface.enter/leave events; with no entered
;;   outputs it keeps the stale impl->scale.  GTK 3.24 (final series,
;;   maintenance-only) has no wl_surface.preferred_buffer_scale or
;;   fractional-scale-v1 support — those are GTK4-only.
;; - After DPMS/suspend, Hyprland sometimes fails to replay
;;   wl_surface.enter when outputs come back, so GDK's scale sits stale
;;   and the compositor upscales the buffer -> blur.
;; - Emacs already handles scale *changes* correctly:
;;   pgtkfns.c:update_watched_scale_factor() polls FRAME_SCALE_FACTOR
;;   once per second per frame (scale_factor_atimer) and force-recreates
;;   the cairo surface on change.  That code is identical on emacs-30
;;   and master, so there is no upstream fix to pick up.  When the bug
;;   hits, the stale state lives inside GDK, and GTK3 exposes no API to
;;   force a buffer scale; the only in-process remedy is destroying and
;;   recreating the wl_surface — which is exactly what
;;   m/replace-selected-frame and m/nudge-wayland-surfaces do.
;;
;; Patching Emacs instead?  Technically possible: in
;; update_watched_scale_factor, compare gtk_widget_get_scale_factor()
;; (GDK's surface scale) with pgtk_frame_scale_factor() (the real
;; monitor scale) and hide/show the outer widget on mismatch to force
;; wl_surface recreation.  But that is the same hack one layer down with
;; the same flicker, has poor odds upstream (it papers over a compositor
;; bug in toolkit-owned territory), and means carrying a patched
;; emacs-wayland package through every update.  Elisp is the right layer
;; for this workaround.
;;
;; Upstream status:
;; - Not an Emacs bug: never tracked in Emacs debbugs, and etc/PROBLEMS
;;   does not mention it.
;; - Hyprland: issue #6560 "monitor on/off makes windows blurry" was
;;   fixed 2024-10 (verified against Emacs at the time); #1839 and
;;   #6928 were closed as duplicates.  The fix later regressed (reports
;;   on 0.51.x/0.52.x through 2025-11); now collected in discussion
;;   #12439, where I reported the Emacs case (2025-12).  Still
;;   reproducible on 0.55.2.  The maintainer asked for a bisect — that
;;   is the path to a real fix.
;;   https://github.com/hyprwm/Hyprland/issues/6560
;;   https://github.com/hyprwm/Hyprland/discussions/12439
;;
;; Compositor-level mitigation: re-applying the monitor rules after
;; wake forces Hyprland to re-announce outputs so every GTK3 app
;; recomputes its scale at once; wired into hypridle's after_sleep_cmd
;; via tilde:nix/files/hypr/scripts/hypr-reapply-monitors.  To give that
;; a fair test (the DBus handler here otherwise replaces the frame on
;; every resume, masking the result), automatic recovery is disabled by
;; default: m/aggressive-wayland-resume-recovery is nil, and
;; M-x m/recover-wayland-after-resume remains as the manual fallback.
;; Set it back to t if blur returns and the compositor fix is not
;; enough.

(defvar m/frame-display-signatures (make-hash-table :test #'eq)
  "Cache display signatures keyed by frame object.")

(defvar m/aggressive-wayland-resume-recovery nil
  "If non-nil, run configured recovery after resume on standalone PGTK Emacs.
This is a pragmatic hack for blur/scale glitches after sleep.
Disabled by default since the compositor-level mitigation in hypridle
(hypr-reapply-monitors) should make it unnecessary; set to t if blur
returns, or run \\[m/recover-wayland-after-resume] manually.")

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
