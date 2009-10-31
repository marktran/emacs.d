;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; mode mappings
(mapc (lambda (mapping) (add-to-list 'auto-mode-alist mapping))
      '(("\\.xml$" . nxml-mode)
        ("\\.yml$" . yaml-mode)))

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

(setq browse-kill-ring-quit-action  'save-and-restore)

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

;; growl
(autoload 'growl "growl" "Emacs interface to Growl" t)

;; ido
(ido-mode t)
(setq ido-create-new-buffer 'always
      ido-enable-flex-matching t)

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

;; recentf
(recentf-mode 1)

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      uniquify-ignore-buffers-re "^\\*")

;; visual line mode
(global-visual-line-mode 1)

;; w3m
(autoload 'w3m "w3m-load" "Interface for w3m on emacs." t)

(eval-after-load 'w3m
  '(progn
     (setq w3m-home-page "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_start")
     (setq w3m-pop-up-windows nil)
     (setq w3m-show-graphic-icons-in-mode-line nil)
     (setq w3m-use-header-line nil)
     (setq w3m-use-tab nil)
     (setq w3m-use-toolbar nil)))

;; yaml
(autoload 'yaml-mode "yaml-mode" "Major mode for editing YAML files" t)

;; yasnippet
(setq yas/prompt-functions '(yas/ido-prompt)
      yas/use-menu 'abbreviate)

(provide 'mqt-modes)
