;; Emacs 27 introduces early-init.el, which is run before init.el,
;; before package and UI initialization happens.

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(when (featurep 'ns)
  (push '(ns-transparent-titlebar . t) default-frame-alist))
(setq-default mode-line-format nil)

;; Set initial frame size and position
(setq initial-frame-alist
      '((width . 150)      ;; Number of columns
        (height . 75)      ;; Number of rows
        (fullscreen . nil))) ;; Set to 'maximized, 'fullscreen, or 'nil

;; Apply the same settings to subsequent frames
(setq default-frame-alist initial-frame-alist)
