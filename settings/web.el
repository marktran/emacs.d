(require-package 'web-mode)

(evil-declare-key 'normal web-mode-map (kbd "%") 'web-mode-tag-match)

(add-auto-mode 'web-mode "\\.erb\\'")
(add-auto-mode 'web-mode "\\.html?\\'")
(add-hook 'web-mode-hook 'emmet-mode)
