(use-package treesit-auto
  :ensure t

  :custom
  (treesit-auto-install t)
  (treesit-auto-langs '(html javascript tsx typescript yaml))

  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))
