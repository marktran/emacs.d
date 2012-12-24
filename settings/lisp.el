(require 'cl)
(require 'eldoc)

(eldoc-add-command 'paredit-backward-delete
                   'paredit-close-round)

(dolist (hook '(emacs-lisp-mode-hook
                lisp-interaction-mode-hook
                lisp-mode-hook
                scheme-mode-hook
                slime-repl-mode-hook))
  (add-hook hook 'paredit-mode))

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
