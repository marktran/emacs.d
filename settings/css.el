(use-package sass-mode
  :ensure t
  :mode
  (("\\.css\\'" . css-mode)
   ("\\.less\\'" . css-mode)
   ("\\.scss\\'" . css-mode))

  :config
  (setq css-indent-offset 2))

(add-hook 'css-mode-hook  'emmet-mode)
