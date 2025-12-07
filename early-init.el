;; Emacs 27 introduces early-init.el, which is run before init.el,
;; before package and UI initialization happens.

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

(defun calculate-font-size ()
  "Calculate appropriate font size based on display characteristics."
  (let* ((display-width (display-pixel-width))
         (display-height (display-pixel-height))
         (display-mm-width (display-mm-width))
         (dpi (if (and display-mm-width (> display-mm-width 0))
                  (/ (* display-width 25.4) display-mm-width)
                0)))
    (cond
     ;; High-DPI displays (>= 2560px width or >= 150 DPI)
     ((or (>= display-width 2560) (>= dpi 150))
      10)
     ;; Medium resolution (1920-2559px or 120-149 DPI)
     ((or (>= display-width 1920) (>= dpi 120))
      14)
     ;; Lower resolution displays
     (t 12))))

(defun set-dynamic-font ()
  "Set font dynamically based on display."
  (let ((font-size (calculate-font-size)))
    (set-face-attribute 'default nil
                        :family "Berkeley Mono"
                        :height (* font-size 10)))) ;; height is in 1/10pt

;; Set initial frame size and position
(setq initial-frame-alist
      '((menu-bar-lines . 0)
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

;; Apply dynamic font sizing
(set-dynamic-font)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (with-selected-frame frame
              (set-dynamic-font))))

; Avoid flash of light
(avoid-initial-flash-of-light)
