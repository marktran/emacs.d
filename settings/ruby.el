(require-package 'enh-ruby-mode)
(require-package 'inf-ruby)
(require-package 'rspec-mode)
(require-package 'ruby-end)

(after-load 'ruby-end (diminish 'ruby-end-mode))

(setq enh-ruby-bounce-deep-indent t
      enh-ruby-hanging-brace-indent-level 2
      rspec-use-rake-flag nil
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-end-insert-newline nil
      ruby-insert-encoding-magic-comment nil)

(add-auto-mode 'enh-ruby-mode
               "Capfile"
               "Gemfile"
               "Guardfile"
               "Rakefile"
               "Vagrantfile"
               "\\.jbuilder\\'"
               "\\.gemspec\\'"
               "\\.rake\\'"
               "\\.ru\\'")

;; http://www.emacswiki.org/emacs/HideShow
(add-to-list 'hs-special-modes-alist
             '(ruby-mode
               "^\\s-*\\(def\\|class\\|module\\|do\\|if\\)" "end" "#"
               (lambda (arg) (ruby-end-of-block)) nil))

(add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
(add-hook 'enh-ruby-mode-hook 'ruby-end-mode)
(add-hook 'enh-ruby-mode-hook 'run-coding-hook)
