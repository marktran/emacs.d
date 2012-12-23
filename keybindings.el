;; function keys
(global-set-key [(f4)] 'ack)
(global-set-key [(f5)] 'query-replace-regexp)
(global-set-key [(f6)] 'kmacro-end-or-call-macro)
(global-set-key [(f12)] (lambda ()
                          (interactive)
                          (kill-buffer (current-buffer))))

(global-set-key [(shift f6)] 'kmacro-start-or-end)

;; completion
(global-set-key (kbd "M-/") 'smart-tab)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-S-t") 'ido-goto-symbol)

;; miscellaneous
(global-set-key (kbd "C-;") 'comment-dwim-line)
(global-set-key (kbd "M-;") 'comment-dwim-line)
(global-set-key (kbd "C-c +") 'increment-number-at-point)
(global-set-key (kbd "C-*") 'isearch-yank-symbol)
(global-set-key (kbd "C-t") 'ido-find-file-in-tag-files)
(global-set-key (kbd "<C-return>") 'textmate-next-line)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

(global-set-key (kbd "M-o") 'other-window)
(add-hook 'dired-mode-hook (lambda () (define-key dired-mode-map (kbd "M-o") 'other-window)))
