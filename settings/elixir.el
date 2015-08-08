(use-package elixir-mode
  :ensure t
  :config

  (add-to-list 'auto-mode-alist '("\\.elixir2\\'" . elixir-mode)))

(use-package alchemist
  :ensure t)
