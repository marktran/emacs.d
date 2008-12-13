;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-libraries.el : Mark Tran <mark@nirv.net>

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))

;; erc
(setq erc-user-full-name "Mark T."
      erc-email-userid "tran"
      erc-nick '("mqt" "qvt")
      erc-server "irc.freenode.net"
      erc-port 6667
      erc-prompt-for-password nil)

;; eshell
(setq eshell-ls-initial-args "-F"
      eshell-ls-use-colors nil)

(setq eshell-prompt-function
  (lambda ()
    (concat "(" (eshell/pwd) ")"
      (if (= (user-uid) 0) " # " " % "))))

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

;; magit
(autoload 'magit-status "magit" "Interface to Git" t)

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
