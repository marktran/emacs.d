;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; mode mappings
(dolist (pattern-mode '(("\\.xml$" . nxml-mode)
                     ("\\.yml$" . yaml-mode)))
  (add-to-list 'auto-mode-alist pattern-mode))

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

(setq browse-kill-ring-quit-action 'save-and-restore)

;; cc
(c-set-offset 'case-label '+)

;; ediff
(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))

;; erc
(autoload 'erc-tls "erc" nil t)
(add-hook 'erc-mode-hook 'turn-on-visual-line-mode)

;; eshell
(setq eshell-ls-initial-args "-F"
      eshell-ls-use-colors nil)

;; find files in a project
(autoload 'find-file-in-project "find-file-in-project" nil t)

;; flymake
(eval-after-load 'flymake
  '(defun flymake-get-tex-args (file-name)
     (list "latex" (list "-file-line-error" file-name))))

;; flyspell
(setq ispell-program-name "aspell")

;; growl
(autoload 'growl "growl" nil t)

;; ido
(ido-mode t)
(ido-everywhere t)

(setq ido-create-new-buffer 'always
      ido-enable-flex-matching t
      ido-use-filename-at-point t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; lua
(autoload 'lua-mode "lua-mode" nil t)

;; magit
(autoload 'magit-status "magit" nil t)

;; makefile
(add-hook 'makefile-mode-hook (lambda() (setq show-trailing-whitespace t)))

;; org
(setq org-hide-leading-stars t
      org-startup-folded nil)

;; paredit
(autoload 'paredit-mode "paredit" nil t)

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                scheme-mode-hook
                slime-repl-mode-hook))
  (add-hook hook 'paredit-mode))

(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd ")")
       'paredit-close-parenthesis)
     (define-key paredit-mode-map (kbd "M-)")
       'paredit-close-parenthesis-and-newline)))

;; recentf
(recentf-mode 1)

;; smex
(autoload 'smex-initialize "smex")

(setq smex-prompt-string "M-x "
      smex-save-file "~/.smex.save")

(eval-after-load "init.el" '(smex-initialize))

;; uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      uniquify-ignore-buffers-re "^\\*")

;; w3m
(autoload 'w3m "w3m-load" nil t)

(eval-after-load 'w3m
  '(setq w3m-home-page 
"http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_start"
         w3m-pop-up-windows nil
         w3m-show-graphic-icons-in-mode-line nil
         w3m-use-header-line nil
         w3m-use-tab nil
         w3m-use-title-buffer-name t
         w3m-use-toolbar nil))

;; yaml
(autoload 'yaml-mode "yaml-mode" nil t)

;; yasnippet
(setq yas/prompt-functions '(yas/ido-prompt)
      yas/use-menu 'abbreviate)

(provide 'mqt-modes)
