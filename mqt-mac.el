;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-mac.el : Mark Tran <mark@nirv.net>

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t)

(add-to-list 'ido-ignore-files "\\.DS_Store")

;; bindings
(setq mac-command-modifier 'control
      mac-option-modifier 'meta)

;; ui
(setq initial-frame-alist
      `((left . 64) (top . 63)
        (width . 185) (height . 55)))
(split-window-horizontally)

(set-default-font "Menlo-12")

(provide 'mqt-mac)
