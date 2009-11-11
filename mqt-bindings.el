;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-bindings.el : Mark Tran <mark@nirv.net>

;; function keys
(global-set-key [(f1)] (lambda ()
                         (interactive) 
                         (switch-or-start 'w3m "w3m")))
(global-set-key [(f2)] (lambda () 
                         (interactive) 
                         (switch-or-start 'gnus "*Group*")))
(global-set-key [(f3)] (lambda () 
                         (interactive) 
                         (erc-tls :server "lambda.nirv.net"
                                  :port 65535
                                  :nick "mqt")))
(global-set-key [(f4)] 'replace-regexp)
(global-set-key [(f5)] 'switch-to-scratch-or-previous)
(global-set-key [(f6)] 'kmacro-end-or-call-macro)
(global-set-key [(f12)] (lambda () 
                          (interactive) 
                          (magit-status default-directory)))

(global-set-key [(shift f6)] 'kmacro-start-or-end)
(global-set-key [(shift f12)] (lambda () 
                                (interactive) 
                                (kill-buffer (current-buffer))))

;; completion
(global-set-key (kbd "<tab>") 'smart-tab)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "M-/") 'hippie-expand)
(global-set-key (kbd "C-t") 'find-file-in-project)
(global-set-key (kbd "C-x f") 'recentf-ido-find-file)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-S-t") 'ido-goto-symbol)

;; miscellaneous
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-/") 'comment-dwim-line)
(global-set-key (kbd "C-c l") 'copy-line)
(global-set-key (kbd "C-c i") 'increment-number-at-point)

;; window movement
(windmove-default-keybindings)

(provide 'mqt-bindings)
