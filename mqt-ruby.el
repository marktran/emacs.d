;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)
(autoload 'rhtml-mode "rhtml-mode" nil t)
(autoload 'rspec-mode "rspec-mode" nil t)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      rspec-use-rake-flag nil
      rspec-use-rvm t
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-electric-expand-delimiters-list nil)

(add-to-list 'auto-mode-alist '("\\.html\\.erb" . rhtml-mode))

(defun ri-bind-key ()
  (local-set-key [f1] 'yari)
  (define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent))

(add-hook 'ruby-mode-hook 'inf-ruby-keys)
(add-hook 'ruby-mode-hook 'ri-bind-key)
(add-hook 'ruby-mode-hook 'ruby-electric-mode)

(provide 'mqt-ruby)
