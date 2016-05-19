(use-package elixir-mode
  :mode "\\.ex\\'" "\\.exs\\'"
  :config
  (require 'alchemist))

(use-package alchemist
  :defer t)
