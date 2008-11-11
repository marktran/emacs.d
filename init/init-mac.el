;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-mac.el : Mark Tran <mark@nirv.net>

;; bindings
(setq mac-command-modifier 'control)
(setq mac-option-modifier 'meta)

;; ui
(set-frame-width (selected-frame) (calculate-columns (display-pixel-width)))
(set-frame-height (selected-frame) (calculate-rows (display-pixel-height)))
(set-frame-position (selected-frame) 
                    (calculate-x-position (car display-padding))
                    (calculate-y-position (car (cdr display-padding))))

(set-default-font 
 "-apple-inconsolata-medium-r-normal--14-0-72-72-m-0-iso10646-1")

(provide 'init-mac)
