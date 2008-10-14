;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-libraries.el : Mark Tran <mark@nirv.net>

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; ido
(ido-mode t)
(setq ido-enable-flex-matching t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; lisppaste
(autoload 'lisppaste-paste-region "lisppaste"
  "Send region to paste.lisp.org" t)

;; lua
(autoload 'lua-mode "lua-mode" "Mode for editing Lua code" t)

;; paredit
(autoload 'paredit-mode "paredit-beta" 
  "Mode for pseudo-structurally editing Lisp code" t)

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                scheme-mode-hook
                slime-repl-mode-hook))
  (add-hook hook #'(lambda nil (paredit-mode 1))))

(eval-after-load 'paredit
  '(progn
    (define-key paredit-mode-map (kbd ")")
     'paredit-close-parenthesis)
    (define-key paredit-mode-map (kbd "M-)")
     'paredit-close-parenthesis-and-newline)))

(provide 'init-libraries)
