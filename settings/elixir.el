(use-package elixir-mode
  :mode "\\.ex\\'" "\\.exs\\'"

  :general
  (:keymaps 'elixir-mode-map
   :states 'normal
   :prefix "SPC"
   "m" '(:ignore t :which-key "Elixir")
   "m a" '(alchemist-phoenix-find-channels :which-key "Find channels")
   "m c" '(alchemist-phoenix-find-controllers :which-key "Find controllers")
   "m m" '(alchemist-phoenix-find-models :which-key "Find models")
   "m r" '(alchemist-phoenix-router :which-key "Jump to router")
   "m s" '(alchemist-phoenix-find-static :which-key "Find static files")
   "m t" '(alchemist-project-find-test :which-key "Find tests")
   "m v" '(alchemist-phoenix-find-views :which-key "Find views")
   "m w" '(alchemist-phoenix-find-web :which-key "Find web files")

   "r" '(:ignore t :which-key "Elixir Tests")
   "j" '(alchemist-project-toggle-file-and-tests :which-key "Toggle source/test file")
   "r a" '(alchemist-mix-test :which-key "Run all tests")
   "r f" '(alchemist-mix-test-this-buffer :which-key "Run tests in buffer")
   "r r" '(alchemist-mix-rerun-last-test :which-key "Rerun tests")
   "r s" '(alchemist-mix-test-at-point :which-key "Run test at point")))

(use-package alchemist
  :ensure elixir-mode
  :diminish alchemist-mode
  :diminish alchemist-phoenix-mode

  :config
  (add-hook 'alchemist-mode-hook 'company-mode))
