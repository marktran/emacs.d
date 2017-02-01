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
   :prefix "SPC"
   "r" '(:ignore t :which-key "Ruby")
   "j" '(rspec-toggle-spec-and-target :which-key "Toggle source/spec file")
   "r a" '(rspec-verify-all :which-key "Run all project specs")
   "r f" '(rspec-verify :which-key "Run specs in buffer")
   "r r" '(rspec-rerun :which-key "Rerun specs")
   "r s" '(rspec-verify-single :which-key "Run spec at point"))

  (:keymaps 'projectile-rails-mode-map
   :states 'normal
   :prefix "SPC"

   "m" '(:ignore t :which-key "Ruby/Rails")
   "m c" '(projectile-rails-find-controller :which-key "Find controller")
   "m d" '(projectile-rails-find-migration :which-key "Find migration")
   "m f" '(flycheck-list-errors :which-key "Flycheck errors")
   "m e" '(projectile-rails-find-environment :which-key "Find environment")
   "m g" '(projectile-rails-goto-gemfile :which-key "Jump to Gemfile")
   "m h" '(projectile-rails-find-helper :which-key "Find helper")
   "m i" '(projectile-rails-find-initializer :which-key "Find initializer")
   "m j" '(projectile-rails-find-javascript :which-key "Find javascript")
   "m l" '(projectile-rails-find-lib :which-key "Find lib")
   "m m" '(projectile-rails-find-model :which-key "Find model")
   "m r" '(projectile-rails-goto-routes :which-key "Jump to routes")
   "m s" '(projectile-rails-find-serializer :which-key "Find serializer")
   "m t" '(projectile-rails-find-spec :which-key "Find spec")
   "m v" '(projectile-rails-find-view :which-key "Find view")
   "m w" '(projectile-rails-find-worker :which-key "Find worker"))

  :config
  (use-package smartparens-ruby :ensure smartparens)
  (use-package inf-ruby)
  (use-package rspec-mode)

  (setq enh-ruby-add-encoding-comment-on-save nil
        enh-ruby-deep-indent-paren nil
        enh-ruby-hanging-brace-indent-level 2
        enh-ruby-use-encoding-map nil
        rspec-compilation-buffer-name "*rspec-compilation*"
        rspec-use-opts-file-when-available nil
        rspec-use-rake-flag nil
        ruby-deep-arglist nil
        ruby-deep-indent-paren nil
        ruby-end-insert-newline nil
        ruby-insert-encoding-magic-comment nil)

  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))

  (add-hook 'enh-ruby-mode-hook 'company-mode)
  (add-hook 'enh-ruby-mode-hook 'flycheck-mode)
  (add-hook 'enh-ruby-mode-hook 'whitespace-cleanup-mode)
  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'enh-ruby-mode-hook 'run-coding-hook))
