(use-package paredit
  :diminish paredit-mode
  :config
  (dolist (hook '(emacs-lisp-mode-hook
                  lisp-interaction-mode-hook
                  lisp-mode-hook
                  scheme-mode-hook
                  slime-repl-mode-hook))
    (add-hook hook 'paredit-mode)))
