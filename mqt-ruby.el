;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)
(autoload 'rhtml-mode "rhtml-mode" nil t)
(autoload 'rspec-mode "rspec-mode" nil t)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      rspec-spec-command "chdir /Users/mark/code/crowdflower/builder && bin/spec"
      rspec-use-rake-flag nil
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-electric-expand-delimiters-list nil)

(add-to-list 'auto-mode-alist '("\\.html\\.erb" . rhtml-mode))

(eval-after-load 'ruby-mode
  '(define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent))

(add-hook 'rinari-minor-mode-hook
          (lambda ()
            (define-key rinari-minor-mode-map (kbd "C-t") 'textmate-goto-file)))
(add-hook 'ruby-mode-hook 'inf-ruby-keys)
(add-hook 'ruby-mode-hook 'ruby-electric-mode)

(provide 'mqt-ruby)
