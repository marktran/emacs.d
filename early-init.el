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

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist))

;; Set initial frame size and position
(setq initial-frame-alist
      '((width . 105)      ;; Number of columns
        (height . 75)      ;; Number of rows
        (fullscreen . nil))) ;; Set to 'maximized, 'fullscreen, or 'nil

;; Apply the same settings to subsequent frames
(setq default-frame-alist initial-frame-alist)

; Avoid flash of light
(avoid-initial-flash-of-light)
