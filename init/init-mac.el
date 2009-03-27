;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-mac.el : Mark Tran <mark@nirv.net>

(add-to-list 'load-path "/opt/local/share/emacs/site-lisp/w3m/")

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      python-python-command "/opt/local/bin/python2.5")

;; bindings
(setq mac-command-modifier 'control
      mac-option-modifier 'meta)

;; ui
;; (set-frame-size (selected-frame) 
;;                 (calculate-columns (display-pixel-width))
;;                 (+ (calculate-rows (display-pixel-height)) 3))
(set-frame-size (selected-frame) 175 50)
;; (set-frame-position (selected-frame) 
;;                     (calculate-x-position (nth 0 display-padding))
;;                     (calculate-y-position (nth 1 display-padding)))
(split-window-horizontally)

(set-default-font "Inconsolata-14")

(provide 'init-mac)
