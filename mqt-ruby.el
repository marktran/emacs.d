;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'ruby-mode "ruby-mode" nil t)

(eval-after-load 'ruby-mode
  '(define-key ruby-mode-map (kbd "RET") 'reindent-then-newline-and-indent))

;; electric
(autoload 'ruby-electric-mode "ruby-electric")
(setq ruby-electric-expand-delimiters-list nil)

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

(add-hook 'ruby-mode-hook
          (lambda ()
            (if (and (not (null buffer-file-name))
                     (file-writable-p buffer-file-name))
                (flymake-ruby-load))))

;; inferior ruby
(autoload 'inf-ruby "inf-ruby" nil t)
(autoload 'inf-ruby-keys "inf-ruby" nil t)

(add-hook 'ruby-mode-hook 'inf-ruby-keys)

;; rcodetools
(eval-after-load 'ruby-mode
  '(require 'rcodetools))

;; ri
(autoload 'ri "ri-ruby.el" nil t)
(setq ri-ruby-script (expand-file-name "~/.emacs.d/vendor/ri-emacs.rb"))

;; rinari
(setq rinari-tags-file-name "TAGS")

(provide 'mqt-ruby)
