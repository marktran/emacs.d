;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; load
(require 'browse-kill-ring)
(require 'diminish)
(require 'dired+)
(require 'elscreen)
(require 'magit)
(require 'peepopen)
(require 'smex)
(require 'undo-tree)
(require 'textmate)
(require 'yasnippet)
;; (load "~/.emacs.d/vendor/nxhtml/autostart.el")
(autoload 'erc-tls "erc" nil t)
(autoload 'growl "growl" nil t)
(autoload 'markdown-mode "markdown-mode" nil t)
(autoload 'w3m "w3m-load" nil t)

(browse-kill-ring-default-keybindings)
(global-undo-tree-mode)
(smex-auto-update)
(textmate-mode)
(toggle-dired-find-file-reuse-dir 1)

;; diminish
(diminish 'eldoc-mode)
(diminish 'undo-tree-mode)
(diminish 'textmate-mode)
(diminish 'visual-line-mode)
(eval-after-load "paredit-beta" '(diminish 'paredit-mode))

;; dired+
(define-key dired-mode-map [mouse-2] 'diredp-mouse-find-file-reuse-dir-buffer)
(add-hook 'dired-mode-hook '(lambda () (dired-omit-mode 1)))

;;
(eval-after-load 'flymake
  '(defun flymake-get-tex-args (file-name)
     (list "latex" (list "-file-line-error" file-name))))
(add-hook 'after-init-hook 'smex-initialize)

;; yasnippet
(yas/initialize)
(yas/load-directory "~/.emacs.d/vendor/yasnippet-0.6.1c/snippets")

;; settings
(setq browse-kill-ring-quit-action 'save-and-restore
      dired-omit-files "^\\.?#\\|^\\.$\\|^\\.DS_Store$"
      elscreen-display-tab nil
      mumamo-chunk-coloring 1
      nxhtml-skip-welcome t
      nxml-degraded t
      rng-nxml-auto-validate-flag nil
      w3m-home-page
"http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_start"
      w3m-pop-up-windows nil
      w3m-show-graphic-icons-in-mode-line nil
      w3m-use-header-line nil
      w3m-use-tab nil
      w3m-use-title-buffer-name t
      w3m-use-toolbar nil
      yas/prompt-functions '(yas/ido-prompt)
      yas/use-menu 'abbreviate)

(provide 'mqt-modes)
