(dolist (mode '(("\\.fish$" . shell-script-mode)
                ("\\.zsh$" . shell-script-mode)))
  (add-to-list 'auto-mode-alist mode))

(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
