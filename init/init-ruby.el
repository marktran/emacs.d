;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'ruby-mode "ruby-mode" "Load ruby-mode")
(autoload 'run-ruby "inf-ruby" "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))

(add-hook 'ruby-mode-hook
          '(lambda ()
             (inf-ruby-keys)))
(add-hook 'ruby-mode-hook 'turn-on-font-lock)

(provide 'init-ruby)
