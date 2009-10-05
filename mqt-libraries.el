;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-libraries.el : Mark Tran <mark@nirv.net>

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; erc
(autoload 'erc-tls "erc"
  "Initiate ERC connection with TLS" t)

;; linum
(setq linum-format "%3d ")

;; lisppaste
(autoload 'lisppaste-paste-region "lisppaste"
  "Send region to paste.lisp.org" t)

;; lua
(autoload 'lua-mode "lua-mode" "Mode for editing Lua code" t)

;; magit
(autoload 'magit-status "magit" "Interface to Git" t)

;; paredit
(autoload 'paredit-mode "paredit" 
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

(provide 'mqt-libraries)
