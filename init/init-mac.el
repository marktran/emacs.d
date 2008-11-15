;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-mac.el : Mark Tran <mark@nirv.net>

(add-to-list 'load-path "/opt/local/share/emacs/site-lisp/w3m/")

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser)

;; bindings
(setq mac-command-modifier 'control)
(setq mac-option-modifier 'meta)

;; ui
(set-frame-size (selected-frame) 
                (calculate-columns (display-pixel-width))
                (calculate-rows (display-pixel-height)))
(set-frame-position (selected-frame) 
                    (calculate-x-position (nth 0 display-padding))
                    (calculate-y-position (nth 1 display-padding)))
(split-window-horizontally)

(set-default-font 
 "-apple-inconsolata-medium-r-normal--14-0-72-72-m-0-iso10646-1")

(provide 'init-mac)
