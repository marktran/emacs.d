;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)
(autoload 'rhtml-mode "rhtml-mode" nil t)
;; (autoload 'ri "ri-ruby.el" nil t)
(autoload 'rspec-mode "rspec-mode" nil t)
;; (autoload 'xmp "rcodetools" nil t)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      ri-ruby-script (expand-file-name "~/.emacs.d/vendor/ri-emacs.rb")
      rinari-major-modes (list 'css-mode-hook
                               'dired-mode-hook
                               'javascript-mode-hook
                               'mumamo-after-change-major-mode-hook
                               'ruby-mode-hook
                               'yaml-mode-hook)
      rspec-spec-command "chdir /Users/mark/code/crowdflower/builder && bin/spec"
      rspec-use-rake-flag nil
      ruby-electric-expand-delimiters-list nil)

(add-to-list 'auto-mode-alist '("\\.html\\.erb" . rhtml-mode))

(eval-after-load 'ruby-mode
  '(define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent))

(add-hook 'rinari-minor-mode-hook
          (lambda ()
            (define-key rinari-minor-mode-map (kbd "C-t") 'textmate-goto-file)))
(add-hook 'ruby-mode-hook 'inf-ruby-keys)
;; (add-hook 'ruby-mode-hook 'rspec-mode)
(add-hook 'ruby-mode-hook 'ruby-electric-mode)

(provide 'mqt-ruby)
