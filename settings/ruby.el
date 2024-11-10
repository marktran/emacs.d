(use-package enh-ruby-mode
  :mode
  (("Capfile" . enh-ruby-mode)
   ("Gemfile\\'" . enh-ruby-mode)
   ("Rakefile" . enh-ruby-mode)
   ("\\.rb" . enh-ruby-mode)
   ("\\.ru" . enh-ruby-mode))

  :interpreter
  ("ruby" . enh-ruby-mode)

  :hook
  ((enh-ruby-mode . company-mode)
   (enh-ruby-mode . flycheck-mode)
   (enh-ruby-mode . whitespace-cleanup-mode)
   (enh-ruby-mode . inf-ruby-minor-mode)
   (enh-ruby-mode . run-coding-hook))

  :custom
  (enh-ruby-add-encoding-comment-on-save nil)
  (enh-ruby-deep-indent-paren nil)
  (enh-ruby-hanging-brace-indent-level 2)
  (enh-ruby-use-encoding-map nil)
  (minitest-use-spring t)
  (rspec-autosave-buffer t)
  (rspec-compilation-buffer-name "*rspec-compilation*")
  (rspec-use-opts-file-when-available nil)
  (rspec-use-rake-flag nil)
  (ruby-deep-arglist nil)
  (ruby-deep-indent-paren nil)
  (ruby-end-insert-newline nil)
  (ruby-insert-encoding-magic-comment nil)

  :general
  (:major-modes 'enh-ruby-mode
   :keymaps 'enh-ruby-mode-map
   :states 'normal
   :prefix "SPC"
   "r" '(:ignore t :which-key "Ruby")
   "j" '(rspec-toggle-spec-and-target :which-key "Toggle source/spec file")
   "r r" '(rspec-rerun :which-key "Rerun last spec invocation"))

  (:major-modes 'enh-ruby-mode
   :keymaps 'minitest-mode-map
   :states 'normal
   :prefix "SPC"
   "r" '(:ignore t :which-key "Ruby")
   "r a" 'minitest-verify-all :which-key "Run all project tests"
   "r f" '(minitest-verify :which-key "Run tests in file")
   "r r" '(minitest-rerun :which-key "Rerun last test invocation")
   "r s" '(minitest-verify-single :which-key "Run test at point"))

  (:major-modes 'enh-ruby-mode
   :keymaps 'rspec-mode-map
   :states 'normal
   :prefix "SPC"
   "r" '(:ignore t :which-key "Ruby")
   "r a" '(rspec-verify-all :which-key "Run all project specs")
   "r f" '(rspec-verify :which-key "Run specs in file")
   "r r" '(rspec-rerun :which-key "Rerun last spec invocation")
   "r s" '(rspec-verify-single :which-key "Run spec at point"))

  (:major-modes 'enh-ruby-mode
   :keymaps 'projectile-rails-mode-map
   :states 'normal
   :prefix "SPC m"
   "" '(:ignore t :which-key "Ruby on Rails")
   "c" '(projectile-rails-find-controller :which-key "Find controller")
   "d" '(projectile-rails-find-migration :which-key "Find migration")
   "f" '(flycheck-list-errors :which-key "Flycheck errors")
   "e" '(projectile-rails-find-environment :which-key "Find environment")
   "g" '(projectile-rails-goto-gemfile :which-key "Jump to Gemfile")
   "h" '(projectile-rails-find-helper :which-key "Find helper")
   "i" '(projectile-rails-find-initializer :which-key "Find initializer")
   "j" '(projectile-rails-find-javascript :which-key "Find javascript")
   "l" '(projectile-rails-find-lib :which-key "Find lib")
   "m" '(projectile-rails-find-model :which-key "Find model")
   "r" '(projectile-rails-goto-routes :which-key "Jump to routes")
   "s" '(projectile-rails-find-serializer :which-key "Find serializer")
   "t" '(projectile-rails-find-spec :which-key "Find spec")
   "v" '(projectile-rails-find-view :which-key "Find view")
   "w" '(projectile-rails-find-worker :which-key "Find worker"))

  (:major-modes 'enh-ruby-mode
   :keymaps 'projectile-rails-mode-map
   :states 'visual
   :prefix "SPC"
   "h" '(ruby-hash-syntax-toggle :which-key "Convert hash style"))

  :init
  (rename-modeline "enh-ruby-mode" enh-ruby-mode "Ruby"))

(use-package smartparens-ruby
  :after enh-ruby-mode
  :ensure smartparens)

(use-package inf-ruby
  :after enh-ruby-mode)

(use-package minitest
  :after enh-ruby-mode)

(use-package rspec-mode
  :after enh-ruby-mode)

(use-package ruby-hash-syntax
  :after enh-ruby-mode)
