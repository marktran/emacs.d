(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)
(autoload 'rspec-mode "rspec-mode" nil t)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      rspec-use-rake-flag nil
      ruby-deep-arglist nil
      ruby-deep-indent-paren nil
      ruby-electric-expand-delimiters-list nil)

(add-hook 'ruby-mode-hook 'inf-ruby-keys)
(add-hook 'ruby-mode-hook 'run-coding-hook)

(dolist (mode '(("Capfile" . ruby-mode)
                ("Gemfile" . ruby-mode)
                ("Guardfile" . ruby-mode)
                ("Rakefile" . ruby-mode)
                ("\\.gemspec$" . ruby-mode)
                ("\\.jbuilder$" . ruby-mode)))
  (add-to-list 'auto-mode-alist mode))

;; functions

;; workaround for ruby-electric breaking yasnippet
;; http://code.google.com/p/yasnippet/issues/detail?id=71#c11
(defun yas/advise-indent-function (function-symbol)
  (eval `(defadvice ,function-symbol (around yas/try-expand-first activate)
           ,(format
             "Try to expand a snippet before point, then call `%s' as usual"
             function-symbol)
           (let ((yas/fallback-behavior nil))
             (unless (and (interactive-p)
                          (yas/expand))
               ad-do-it)))))

(yas/advise-indent-function 'ruby-indent-line)
