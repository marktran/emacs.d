;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-keybindings.el : Mark Tran <mark@nirv.net>

;; function keys
(global-set-key [(meta f1)] 'w3m)
(global-set-key [(meta f2)] 'gnus)
(global-set-key [(meta f3)] 'switch-to-scratch-or-previous)
(global-set-key [(meta f4)] '(lambda ()
                        (interactive)
                        (if (get-buffer "*scheme*")
                         (switch-to-buffer "*scheme*"))))
(global-set-key [(meta f5)] 'slime)
(global-set-key [(meta f6)] 'replace-regexp)
(global-set-key [(meta f7)] 'kmacro-end-or-call-macro)
(global-set-key [(meta f12)] '(lambda () 
                         (interactive) 
                         (magit-status default-directory)))

(global-set-key [(meta shift f12)] '(lambda () 
                                   (interactive) 
                                   (kill-buffer (current-buffer))))

(global-set-key [(meta shift f7)] 'kmacro-start-or-end)

;; miscellaneous
(global-set-key (kbd "C-<tab>") 'bury-buffer)
(global-set-key (kbd "M-<tab>") 'smart-tab)

(global-set-key (kbd "C-c l") 'copy-line)
(global-set-key (kbd "C-c t") 'increment-number-at-point)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

;; window movement
(global-set-key (kbd "M-s-b") 'windmove-left)
(global-set-key (kbd "M-s-f") 'windmove-right)
(global-set-key (kbd "M-s-p") 'windmove-up)
(global-set-key (kbd "M-s-n") 'windmove-down)
(global-set-key [XF86Back] 'windmove-left)
(global-set-key [XF86Forward] 'windmove-right)

(provide 'init-keybindings)
