;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/ruby.el : Mark Tran <mark@nirv.net>

(autoload 'ruby-mode "ruby-mode" "Load ruby-mode")
(setq auto-mode-alist
      (append '(("\\.rb$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))

(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
          '(lambda ()
             (inf-ruby-keys)))

(add-hook 'ruby-mode-hook 'turn-on-font-lock)

(provide 'ruby)
