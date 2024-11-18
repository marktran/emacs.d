(use-package evil
  :ensure t

  :init
  (setq-default evil-shift-width 2)

  :custom
  (evil-ex-search-vim-style-regexp t)   ; Use Vim-style regular expressions in searches
  (evil-mode-line-format nil)           ; Disable mode line indicator for Evil
  (evil-symbol-word-search t)           ; Treat symbols as words in searches
  (evil-want-C-u-scroll t)              ; Enable Vim-like C-u scrolling
  (evil-want-Y-yank-to-eol t)           ; Make Y behave like Vim (yank to end of line)
  (evil-want-keybinding nil)            ; Avoid conflicts with Evil Collection

  :config
  (evil-mode 1)

  ;; Set initial states for specific modes
  (dolist (mode-state '((inferior-emacs-lisp-mode . emacs)
                        (comint-mode              . emacs)
                        (eat-mode                 . emacs)
                        (eshell-mode              . emacs)
                        (occur-mode               . emacs)
                        (org-mode                 . normal)
                        (special-mode             . normal)
                        (sql-interactive-mode     . emacs)
                        (yaml-mode                . normal)))
    (cl-destructuring-bind (mode . state) mode-state
      (evil-set-initial-state mode state))))

(use-package evil-collection
  :ensure t
  :after evil
  :diminish evil-collection-unimpaired-mode

  :config
  (evil-collection-init 'dired)
  (evil-collection-init 'ediff)
  (evil-collection-init 'magit))

(use-package evil-escape
  :ensure t
  :after evil
  :diminish evil-escape-mode

  :custom
  (evil-escape-key-sequence "jk")

  :config
  (evil-escape-mode 1))

(use-package evil-iedit-state
  :ensure t
  :after evil
  :commands evil-iedit-state/iedit-mode)

(use-package evil-lion
  :ensure t
  :after evil
  :config
  (evil-lion-mode 1))

(use-package evil-matchit
  :ensure t
  :after evil
  :init
  (global-evil-matchit-mode 1))

(use-package evil-nerd-commenter
  :ensure t
  :after evil
  :commands evilnc-comment-or-uncomment-lines)

(use-package evil-numbers
  :ensure t
  :after evil
  :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-t))

(use-package evil-surround
  :ensure t
  :after evil
  :init
  (global-evil-surround-mode 1))

(evil-collection-init 'evil-dired)
