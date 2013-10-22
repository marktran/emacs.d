(require-package 'web-mode)

(add-auto-mode 'web-mode "\\.erb\\'")
(add-auto-mode 'web-mode "\\.html?\\'")
(add-hook 'web-mode-hook 'emmet-mode)
