;;; .emacs.d/mqt-keybindings.el : Mark Tran <mark@nirv.net>

;; function keys
(global-set-key [(f2)] 'gnus)
(global-set-key [(f3)] 'magit-status)
(global-set-key [(f4)] 'ack)
(global-set-key [(f5)] 'replace-regexp)
(global-set-key [(f6)] 'kmacro-end-or-call-macro)
(global-set-key [(f7)] 'bookmark-ido-find-file)
(global-set-key [(f11)] 'ns-toggle-fullscreen)
(global-set-key [(f12)] (lambda ()
                          (interactive)
                          (kill-buffer (current-buffer))))

(global-set-key [(shift f6)] 'kmacro-start-or-end)

;; completion
(global-set-key (kbd "M-/") 'smart-tab)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-x C-r") 'recentf-ido-find-file)
(global-set-key (kbd "C-x C-b") 'ido-switch-buffer)
(global-set-key (kbd "C-S-t") 'ido-goto-symbol)

;; miscellaneous
(global-set-key (kbd "C-;") 'comment-dwim-line)
(global-set-key (kbd "M-;") 'comment-dwim-line)
(global-set-key (kbd "C-c +") 'increment-number-at-point)
(global-set-key (kbd "C-*") 'isearch-yank-symbol)
(global-set-key (kbd "C-t") 'textmate-goto-file)
(global-set-key (kbd "<C-return>") 'textmate-next-line)
(global-set-key (kbd "M-[") 'textmate-shift-left)
(global-set-key (kbd "M-]") 'textmate-shift-right)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

;; window
(global-set-key (kbd "C-x t") 'transpose-windows)
(global-set-key (kbd "C-{") 'windmove-left)
(global-set-key (kbd "C-}") 'windmove-right)
(global-set-key (kbd "<left>") 'windmove-left)
(global-set-key (kbd "<right>") 'windmove-right)
(global-set-key (kbd "<up>") 'windmove-up)
(global-set-key (kbd "<down>") 'windmove-down)

(global-set-key (kbd "<down-mouse-4>") 'escreen-goto-prev-screen)
(global-set-key (kbd "<down-mouse-5>") 'escreen-goto-next-screen)

(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd "C-{") 'windmove-left)
     (define-key paredit-mode-map (kbd "C-}") 'windmove-right)))

(global-set-key (kbd "M-o") 'other-window)
(add-hook 'dired-mode-hook (lambda () (define-key dired-mode-map (kbd "M-o") 'other-window)))

(provide 'mqt-keybindings)
