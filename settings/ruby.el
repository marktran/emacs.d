(use-package enh-ruby-mode
  :mode
  (("Capfile" . enh-ruby-mode)
   ("Gemfile" . ruby-mode)
   ("Rakefile" . ruby-mode)
   ("\\.rb" . ruby-mode)
   ("\\.ru" . enh-ruby-mode))

  :config
  (use-package smartparens-ruby :ensure smartparens)
  (use-package inf-ruby)
  (require 'rspec-mode)

  (setq enh-ruby-add-encoding-comment-on-save nil
        enh-ruby-deep-indent-paren nil
        enh-ruby-hanging-brace-indent-level 2
        enh-ruby-use-encoding-map nil
        rspec-use-rake-flag nil
        ruby-deep-arglist nil
        ruby-deep-indent-paren nil
        ruby-end-insert-newline nil
        ruby-insert-encoding-magic-comment nil)

  (add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))

  (add-hook 'ruby-mode-hook 'company-mode)
  (add-hook 'ruby-mode-hook 'whitespace-cleanup-mode)
  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'enh-ruby-mode-hook 'run-coding-hook))

(use-package rspec-mode
  :defer t

  :commands
  (rspec-rerun
   rspec-toggle-spec-and-target
   rspec-verify
   rspec-verify-single)

  :config
  (setq rspec-compilation-buffer-name "*rspec-compilation*"))
