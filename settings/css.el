(require-package 'sass-mode)

(setq css-indent-offset 2)
(add-auto-mode 'css-mode "\\.css\\'" "\\.less\\'" "\\.scss\\'")
(add-hook 'css-mode-hook  'emmet-mode)
