;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-scheme.el : Mark Tran <mark@nirv.net>

(autoload 'quack-scheme-mode-hookfunc "quack")
(autoload 'quack-inferior-scheme-mode-hookfunc "quack")

(eval-after-load 'quack
   '(progn
      (setq quack-default-program "mzscheme -i -l errortrace"
            quack-fontify-style 'plt
            quack-global-menu-p nil
            quack-remap-find-file-bindings-p nil
            quack-run-scheme-always-prompts-p nil
            quack-run-scheme-prompt-defaults-to-last-p t
            quack-tabs-are-evil-p t)))

(add-hook 'scheme-mode-hook 'quack-scheme-mode-hookfunc)
(add-hook 'inferior-scheme-mode-hook 'quack-inferior-scheme-mode-hookfunc)

(provide 'init-scheme)
