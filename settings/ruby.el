(use-package enh-ruby-mode
  :mode
  (("Capfile" . enh-ruby-mode)
   ("Gemfile" . enh-ruby-mode)
   ("Rakefile" . enh-ruby-mode)
   ("\\.rb" . enh-ruby-mode)
   ("\\.ru" . enh-ruby-mode))

  :config
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

  (add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'enh-ruby-mode-hook 'run-coding-hook))

(use-package inf-ruby)

(use-package rspec-mode
  :config
  (setq rspec-compilation-buffer-name "*rspec-compilation*"))
