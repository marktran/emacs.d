;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; mode mappings
(mapc (lambda (mapping) (add-to-list 'auto-mode-alist mapping))
      '(("\\.dtd$" . xml-mode)
        ("\\.lua$" . lua-mode)
        ("\\.xml$" . xml-mode)
        ("\\.yml$" . conf-mode)))

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; cc
(c-set-offset 'case-label '+)

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))

;; erc
(autoload 'erc-tls "erc"
  "Initiate ERC connection with TLS" t)

;; eshell
(setq eshell-ls-initial-args "-F"
      eshell-ls-use-colors nil)

;; hl-line
(global-hl-line-mode 1)

;; ido
(ido-mode t)
(setq ido-enable-flex-matching t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; linum
(setq linum-format "%3d ")

;; lisppaste
(autoload 'lisppaste-paste-region "lisppaste"
  "Send region to paste.lisp.org" t)

;; lua
(autoload 'lua-mode "lua-mode" "Mode for editing Lua code" t)

;; magit
(autoload 'magit-status "magit" "Interface to Git" t)

;; makefile
(add-hook 'makefile-mode-hook 
  (lambda()
    (setq show-trailing-whitespace t)))

;; org
(setq org-hide-leading-stars t
      org-startup-folded nil)

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

;; text-mode
(add-hook 'text-mode-hook 'turn-on-auto-fill)

(provide 'mqt-modes)
