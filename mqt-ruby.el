;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-ruby.el : Mark Tran <mark@nirv.net>

(autoload 'ruby-mode "ruby-mode" t)
(autoload 'run-ruby "inf-ruby")
(autoload 'inf-ruby-keys "inf-ruby")

(add-hook 'ruby-mode-hook (lambda () (inf-ruby-keys)))

(provide 'mqt-ruby)
