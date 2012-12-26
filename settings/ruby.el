(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      rspec-use-rake-flag nil
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-electric-expand-delimiters-list nil)

(dolist (mode '(("Capfile" . ruby-mode)
                ("Gemfile" . ruby-mode)
                ("Guardfile" . ruby-mode)
                ("Rakefile" . ruby-mode)
                ("Vagrantfile" . ruby-mode)
                ("\\.rake$" . ruby-mode)
                ("\\.gemspec$" . ruby-mode)
                ("\\.jbuilder$" . ruby-mode)))
  (add-to-list 'auto-mode-alist mode))

(add-hook 'ruby-mode-hook 'run-coding-hook)
