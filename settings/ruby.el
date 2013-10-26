(require-package 'ruby-additional)
(require-package 'inf-ruby)
(require-package 'rspec-mode)
(require-package 'ruby-electric)

(require 'ruby-additional)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      rspec-use-rake-flag nil
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-electric-expand-delimiters-list nil
      ruby-insert-encoding-magic-comment nil)

(add-auto-mode 'ruby-mode
               "Capfile"
               "Gemfile"
               "Guardfile"
               "Rakefile"
               "Vagrantfile"
               "\\.rake\\'"
               "\\.gemspec\\'"
               "\\.jbuilder\\'")

;; http://www.emacswiki.org/emacs/HideShow
(add-to-list 'hs-special-modes-alist
             '(ruby-mode
               "^\\s-*\\(def\\|class\\|module\\|do\\|if\\)" "end" "#"
               (lambda (arg) (ruby-end-of-block)) nil))

(add-hook 'ruby-mode-hook 'ruby-electric-mode)
(add-hook 'ruby-mode-hook 'run-coding-hook)
