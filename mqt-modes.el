;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; load
(require 'bookmark)
(require 'browse-kill-ring)
(require 'coffee-mode)
(require 'diminish)
(require 'dired+)
(require 'elscreen)
(require 'scratch)
(require 'smex)
(require 'switch-window)
(require 'undo-tree)
(require 'textmate)
(require 'tramp)
(require 'yasnippet)
(autoload 'coffee-mode "coffee-mode" nil t)
(autoload 'django-html-mode "django-html-mode" nil t)
(autoload 'erc-tls "erc" nil t)
(autoload 'magit-status "magit" nil t)
(autoload 'markdown-mode "markdown-mode" nil t)
(autoload 'mode-compile "mode-compile" nil t)
(autoload 'w3m "w3m-load" nil t)

(autopair-global-mode)
(browse-kill-ring-default-keybindings)
(global-undo-tree-mode)
(smex-auto-update)
(textmate-mode)
(toggle-dired-find-file-reuse-dir 1)

;; coffee
(defun coffee-custom ()
  (set (make-local-variable 'tab-width) 2)
  (setq coffee-js-mode 'javascript-mode)

  (define-key coffee-mode-map [(meta r)] 'coffee-compile-buffer))

(add-hook 'coffee-mode-hook '(lambda() (coffee-custom)))

;; diminish
(diminish 'autopair-mode)
(diminish 'eldoc-mode)
(diminish 'textmate-mode)
(diminish 'undo-tree-mode)
(diminish 'visual-line-mode)
(diminish 'yas/minor-mode)
(eval-after-load "paredit" '(diminish 'paredit-mode))
(eval-after-load "ruby-electric" '(diminish 'ruby-electric-mode))
(eval-after-load "whitespace" '(diminish 'whitespace-mode " W"))

;; dired+
(define-key dired-mode-map [mouse-2] 'diredp-mouse-find-file-reuse-dir-buffer)
(add-hook 'dired-mode-hook '(lambda () (dired-omit-mode 1)))

;; dired-isearch
(define-key dired-mode-map (kbd "C-s") 'dired-isearch-forward)
(define-key dired-mode-map (kbd "C-r") 'dired-isearch-backward)
(define-key dired-mode-map (kbd "ESC C-s") 'dired-isearch-forward-regexp)
(define-key dired-mode-map (kbd "ESC C-r") 'dired-isearch-backward-regexp)

;; flymake
(eval-after-load 'flymake
  '(defun flymake-get-tex-args (file-name)
     (list "latex" (list "-file-line-error" file-name))))
(add-hook 'after-init-hook 'smex-initialize)

;; settings
(setq ack-prompt-for-directory t
      bookmark-default-file "~/.emacs.d/.emacs.bmk"
      browse-kill-ring-quit-action 'save-and-restore
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
      yas/use-menu 'abbreviate
      yas/root-directory '("~/.emacs.d/snippets"
                           "~/.emacs.d/el-get/yasnippet/snippets")
      zencoding-preview-default nil)

;; yasnippet
(yas/initialize)
(mapc 'yas/load-directory yas/root-directory)

(provide 'mqt-modes)
