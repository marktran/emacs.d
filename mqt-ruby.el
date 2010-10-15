;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)
(autoload 'rhtml-mode "rhtml-mode" nil t)
(autoload 'ri "ri-ruby.el" nil t)
(autoload 'rspec-mode "rspec-mode" nil t)
(autoload 'xmp "rcodetools" nil t)

(setq erb-type-to-delim-face nil
      erb-type-to-face nil
      ri-ruby-script (expand-file-name "~/.emacs.d/vendor/ri-emacs.rb")
      rinari-major-modes (list 'css-mode-hook
                               'dired-mode-hook
                               'javascript-mode-hook
                               'mumamo-after-change-major-mode-hook
                               'ruby-mode-hook
                               'yaml-mode-hook)
      rspec-spec-command "chdir /Users/marktran/code/crowdflower/builder && bin/spec"
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

;; flymake
(defvar flymake-ruby-err-line-patterns
  '(("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3)))
(defvar flymake-ruby-allowed-file-name-masks
  '((".+\\.\\(rb\\|rake\\)$" flymake-ruby-init)
    ("Rakefile$" flymake-ruby-init)))

(defun flymake-create-temp-in-system-tempdir (filename prefix)
  (make-temp-file (or prefix "flymake-ruby")))

(defun flymake-ruby-init ()
  (list "ruby" (list "-c" (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-in-system-tempdir))))

(defun flymake-ruby-load ()
  (interactive)
  (set (make-local-variable 'flymake-allowed-file-name-masks)
       flymake-ruby-allowed-file-name-masks)
  (set (make-local-variable 'flymake-err-line-patterns)
       flymake-ruby-err-line-patterns)
  (flymake-mode t))

;; (add-hook 'ruby-mode-hook
;;           (lambda ()
;;             (if (and (not (null buffer-file-name))
;;                      (file-writable-p buffer-file-name))
;;                 (flymake-ruby-load))))

(provide 'mqt-ruby)
