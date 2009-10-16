;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-mac.el : Mark Tran <mark@nirv.net>

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t)

;; bindings
(setq mac-command-modifier 'control
      mac-option-modifier 'meta)

;; ui
(set-frame-size (selected-frame) 
                (calculate-columns (display-pixel-width))
                (calculate-rows (display-pixel-height)))

(set-frame-position (selected-frame) 
                    (calculate-x-position (nth 0 display-padding))
                    (calculate-y-position (nth 1 display-padding)))

(split-window-horizontally)

(set-default-font "Menlo-12")

(provide 'mqt-mac)
