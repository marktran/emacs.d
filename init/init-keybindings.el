;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-keybindings.el : Mark Tran <mark@nirv.net>

(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

;; window movement
(global-set-key (kbd "M-s-b") 'windmove-left)
(global-set-key (kbd "M-s-f") 'windmove-right)
(global-set-key (kbd "M-s-p") 'windmove-up)
(global-set-key (kbd "M-s-n") 'windmove-down)

(global-set-key [XF86Back] 'windmove-left)
(global-set-key [XF86Forward] 'windmove-right)

(provide 'init-keybindings)
