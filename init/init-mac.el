;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-mac.el : Mark Tran <mark@nirv.net>

;; bindings
(setq mac-command-modifier 'control)
(setq mac-option-modifier 'meta)

;; ui
(set-frame-width (selected-frame) 190)
(set-frame-height (selected-frame) 50)
(set-frame-position (selected-frame) 50 -40)

;;
(setenv "PATH" (concat "/opt/local/bin" ":" (getenv "PATH")))

(provide 'init-mac)
