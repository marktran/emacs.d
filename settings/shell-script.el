(setq sh-basic-offset 2)

(add-auto-mode 'shell-script-mode "\\.fish\\'" "\\.zsh\\'")
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
