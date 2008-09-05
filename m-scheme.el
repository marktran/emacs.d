;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/m-scheme.el : Mark Tran <mark@nirv.net>

(require 'quack)

(setq
 quack-default-program "mzscheme -i -l errortrace"
 quack-fontify-style 'emacs
 quack-global-menu-p nil
 quack-remap-find-file-bindings-p nil
 quack-run-scheme-always-prompts-p nil
 quack-run-scheme-prompt-defaults-to-last-p t
 quack-tabs-are-evil-p t)

(provide 'm-scheme)
