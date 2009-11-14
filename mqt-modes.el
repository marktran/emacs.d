;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; browse-kill-ring
(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

(setq browse-kill-ring-quit-action 'save-and-restore)

;; erc
(autoload 'erc-tls "erc" nil t)

(add-hook 'erc-mode-hook 'turn-on-visual-line-mode)

;; find files in a project
(autoload 'find-file-in-project "find-file-in-project" nil t)

;; flymake
(eval-after-load 'flymake
  '(defun flymake-get-tex-args (file-name)
     (list "latex" (list "-file-line-error" file-name))))

;; growl
(autoload 'growl "growl" nil t)

;; paredit
(autoload 'paredit-mode "paredit-beta" nil t)

(eval-after-load 'paredit
  '(progn
     (define-key paredit-mode-map (kbd ")")
       'paredit-close-parenthesis)
     (define-key paredit-mode-map (kbd "M-)")
       'paredit-close-parenthesis-and-newline)))

;; smex
(autoload 'smex-initialize "smex")

(setq smex-prompt-string "M-x "
      smex-save-file "~/.smex.save")

(eval-after-load "init.el" '(smex-initialize))

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
