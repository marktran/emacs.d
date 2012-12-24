(add-to-list 'auto-mode-alist '("\\.zsh$" shell-script-mode))
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
