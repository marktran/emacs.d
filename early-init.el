;; This file runs before init.el, ahead of package and UI initialization.

(defun re-enable-frame-theme (_frame)
  "Re-enable active theme, if any, upon FRAME creation.
Add this to `after-make-frame-functions' so that new frames do
not retain the generic background set by the function
`avoid-initial-flash-of-light'."
  (when-let* ((theme (car custom-enabled-themes)))
    (enable-theme theme)))

(defun avoid-initial-flash-of-light ()
  "Avoid flash of light when starting Emacs, if needed.
New frames are instructed to call `prot-emacs-re-enable-frame-theme'."
  (setq mode-line-format nil)
  (set-face-attribute 'default nil :background "#000000" :foreground "#ffffff")
  (set-face-attribute 'mode-line nil :background "#000000" :foreground "#ffffff" :box 'unspecified)
  (add-hook 'after-make-frame-functions #'re-enable-frame-theme))

(defvar m/font-size-overrides
  '(("Studio Display" . 12)
    ("ATNA40HQ02" . 10)
    ("eDP" . 10)
    ("Built-in" . 10)
    ("Retina" . 10)
    ("Color LCD" . 10))
  "Monitor name regex overrides for font size.")

(defconst m/default-font-family "Berkeley Mono"
  "Default font family used during startup.")

(defconst m/default-font-size 10
  "Default font size used during startup.")

(defvar m/monitor-font-size-cache (make-hash-table :test #'equal)
  "Cache font sizes keyed by monitor identity.")

(defun m/font-size-override-for-monitor (name)
  "Return font-size override for monitor NAME, or nil."
  (when name
    (catch 'size
      (dolist (pair m/font-size-overrides)
        (when (string-match-p (car pair) name)
          (throw 'size (cdr pair))))
      nil)))

(defun m/display-metric (frame fn)
  "Evaluate FN on FRAME's display."
  (if (and frame (frame-live-p frame))
      (with-selected-frame frame
        (funcall fn))
    (funcall fn)))

(defun m/frame-scale (frame)
  "Return scale factor for FRAME, defaulting to 1.0."
  (let ((scale (ignore-errors
                 (if (and frame (frame-live-p frame))
                     (frame-scale-factor frame)
                   (frame-scale-factor)))))
    (if (and (numberp scale) (> scale 0))
        scale
      1.0)))

(defun m/monitor-attributes (&optional frame)
  "Return monitor attributes for FRAME or nil."
  (ignore-errors (frame-monitor-attributes frame)))

(defun m/monitor-name (&optional frame)
  "Return monitor name string for FRAME."
  (let ((name (cdr-safe (assq 'name (m/monitor-attributes frame)))))
    (and name (format "%s" name))))

(defun m/monitor-mm-width (&optional frame)
  "Return physical monitor width in millimeters for FRAME."
  (car-safe (cdr-safe (assq 'mm-size (m/monitor-attributes frame)))))

(defun m/monitor-id (&optional frame)
  "Return a stable cache key for FRAME's monitor."
  (let* ((attrs (m/monitor-attributes frame))
         (name (cdr-safe (assq 'name attrs)))
         (mm-size (cdr-safe (assq 'mm-size attrs)))
         (geometry (cdr-safe (assq 'geometry attrs)))
         (width (nth 2 geometry))
         (height (nth 3 geometry)))
    (when (or name mm-size width height)
      (list name mm-size width height (m/frame-scale frame)))))

(defun m/monitor-width-and-dpi (&optional frame)
  "Return (WIDTH . DPI) for FRAME's monitor."
  (let* ((attrs (m/monitor-attributes frame))
         (geometry (cdr-safe (assq 'geometry attrs)))
         (mm-size (cdr-safe (assq 'mm-size attrs)))
         (width (or (nth 2 geometry)
                    (ignore-errors (m/display-metric frame #'display-pixel-width))))
         (mm-width (or (car-safe mm-size)
                       (let ((value (ignore-errors
                                      (m/display-metric frame #'display-mm-width))))
                         (and (numberp value)
                              (> value 0)
                              value))))
         (logical-dpi (when (and (numberp width)
                                 (> width 0)
                                 (numberp mm-width)
                                 (> mm-width 0))
                        (/ (* width 25.4) mm-width)))
         (dpi (when logical-dpi
                (* logical-dpi (m/frame-scale frame)))))
    (cons width dpi)))

(defun calculate-font-size (&optional frame)
  "Calculate appropriate font size based on display characteristics."
  (pcase-let* ((`(,display-width . ,dpi) (m/monitor-width-and-dpi frame))
               (name (m/monitor-name frame))
               (mm-width (m/monitor-mm-width frame))
               (override (m/font-size-override-for-monitor name)))
    (cond
     ;; Explicit monitor overrides by name.
     (override
      override)
     ;; Small laptop panels.
     ((and (numberp mm-width) (> mm-width 0) (<= mm-width 320))
      10)
     ;; Large external monitors.
     ((and (numberp mm-width) (>= mm-width 500))
      12)
     ;; High DPI displays.
     ((and dpi (>= dpi 170))
      10)
     ;; Medium DPI displays.
     ((and dpi (>= dpi 120))
      12)
     ;; Fallbacks when DPI is unavailable (common early in Wayland startup).
     ((and (null dpi) display-width (>= display-width 2560))
      10)
     ((and (null dpi) display-width (>= display-width 1920))
      12)
     ;; Lower resolution displays
     (t 12))))

(defun m/frame-font-size (&optional frame)
  "Return a stable font size for FRAME's monitor."
  (let* ((id (m/monitor-id frame))
         (cached (and id (gethash id m/monitor-font-size-cache 'missing))))
    (if (and id (not (eq cached 'missing)))
        cached
      (let ((size (calculate-font-size frame)))
        ;; During early startup under Wayland, monitor metrics may be unset.
        ;; Cache only once Emacs is initialized so we don't lock in a bad value.
        (when (and id after-init-time)
          (puthash id size m/monitor-font-size-cache))
        size))))

(defun set-dynamic-font (&optional frame)
  "Set font dynamically based on display."
  (let* ((font-size (m/frame-font-size frame))
         (height (* font-size 10))
         (target (or frame nil)))
    (unless (equal (face-attribute 'default :height target) height)
      (set-face-attribute 'default target
                          :family m/default-font-family
                          :height height)))) ;; height is in 1/10pt

;; Set initial frame size and position
(setq initial-frame-alist
      `((font . ,(format "%s-%d" m/default-font-family m/default-font-size))
        (menu-bar-lines . 0)
        (tool-bar-lines . 0)
        (vertical-scroll-bars)
        (width . 105)      ;; Number of columns
        (height . 75)      ;; Number of rows
        (fullscreen . nil))) ;; Set to 'maximized, 'fullscreen, or 'nil

;; Add ns-specific settings if on macOS
(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) initial-frame-alist))

;; Apply the same settings to subsequent frames
(setq default-frame-alist initial-frame-alist)
(set-face-attribute 'default nil
                    :family m/default-font-family
                    :height (* m/default-font-size 10))

;; Apply dynamic font sizing
(add-hook 'window-setup-hook
          (lambda ()
            (set-dynamic-font (selected-frame))))
(add-hook 'after-make-frame-functions #'set-dynamic-font)

;; Wayland sleep/resume blur hack is isolated in a dedicated module.
(load "~/.emacs.d/lisp/hacks/wayland-resume-hack.el" 'noerror)

; Avoid flash of light
(avoid-initial-flash-of-light)
