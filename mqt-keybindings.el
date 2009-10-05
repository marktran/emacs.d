;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-keybindings.el : Mark Tran <mark@nirv.net>

;; function keys
(global-set-key [(meta f1)] (lambda ()
                              (interactive) 
                              (switch-or-start 'w3m "w3m")))
(global-set-key [(meta f2)] (lambda () 
                              (interactive) 
                              (switch-or-start 'gnus "*Group*")))
(global-set-key [(meta f3)] '(lambda () 
                                (interactive) 
                                (erc-tls :server "lambda.nirv.net"
                                         :port 65535
                                         :nick "mqt")))
(global-set-key [(meta f4)] 'replace-regexp)
(global-set-key [(meta f5)] 'switch-to-scratch-or-previous)
(global-set-key [(meta f6)] 'kmacro-end-or-call-macro)
(global-set-key [(meta f12)] '(lambda () 
                                (interactive) 
                                (magit-status default-directory)))


(global-set-key [(meta shift f6)] 'kmacro-start-or-end)
(global-set-key [(meta shift f12)] '(lambda () 
                                      (interactive) 
                                      (kill-buffer (current-buffer))))

;; miscellaneous
(global-set-key (kbd "M-<tab>") 'smart-tab)

(global-set-key (kbd "C-c l") 'copy-line)
(global-set-key (kbd "C-c t") 'increment-number-at-point)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)

(global-set-key (kbd "M-/") 'hippie-expand)

;; window movement
(global-set-key (kbd "M-s-b") 'windmove-left)
(global-set-key (kbd "M-s-f") 'windmove-right)
(global-set-key (kbd "M-s-p") 'windmove-up)
(global-set-key (kbd "M-s-n") 'windmove-down)
(global-set-key [XF86Back] 'windmove-left)
(global-set-key [XF86Forward] 'windmove-right)

(provide 'mqt-keybindings)
