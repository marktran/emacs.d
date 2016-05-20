(use-package css-mode
  :mode "\\.css\\'"
  :config
  (setq css-indent-offset 2)
  (add-hook 'css-mode-hook 'emmet-mode))
