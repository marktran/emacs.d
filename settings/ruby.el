(use-package enh-ruby-mode
  :mode
  (("Capfile" . enh-ruby-mode)
   ("Gemfile" . enh-ruby-mode)
   ("Rakefile" . enh-ruby-mode)
   ("\\.rb" . enh-ruby-mode)
   ("\\.ru" . enh-ruby-mode))

  :general
  (:keymaps 'enh-ruby-mode-map
   :states 'normal
   "r" '(:ignore t :which-key "Ruby")
   "j" '(rspec-toggle-spec-and-target :which-key "Toggle source/spec file")
   "r f" '(rspec-verify :which-key "Run specs in buffer")
   "r r" '(rspec-rerun :which-key "Rerun specs")
   "r s" '(rspec-verify-single :which-key "Run spec at point"))

  :config
  (use-package smartparens-ruby :ensure smartparens)
  (use-package inf-ruby)
  (use-package rspec-mode)

  (setq enh-ruby-add-encoding-comment-on-save nil
        enh-ruby-deep-indent-paren nil
        enh-ruby-hanging-brace-indent-level 2
        enh-ruby-use-encoding-map nil
        rspec-compilation-buffer-name "*rspec-compilation*"
        rspec-use-rake-flag nil
        ruby-deep-arglist nil
        ruby-deep-indent-paren nil
        ruby-end-insert-newline nil
        ruby-insert-encoding-magic-comment nil)

  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))

  (add-hook 'enh-ruby-mode-hook 'company-mode)
  (add-hook 'enh-ruby-mode-hook 'whitespace-cleanup-mode)
  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'enh-ruby-mode-hook 'run-coding-hook))
