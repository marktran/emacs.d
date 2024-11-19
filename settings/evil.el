(use-package evil
  :ensure t

  :custom
  (evil-ex-search-vim-style-regexp t) ; Use Vim-style regular expressions in searches
  (evil-mode-line-format nil)         ; Disable mode line indicator for Evil
  (evil-shift-width 2)                ; Set the width for `>>` and `<<` commands
  (evil-symbol-word-search t)         ; Treat symbols as words in searches
  (evil-want-C-u-scroll t)            ; Enable Vim-like C-u scrolling
  (evil-want-Y-yank-to-eol t)         ; Make Y behave like Vim (yank to end of line)
  (evil-want-keybinding nil)          ; Avoid conflicts with Evil Collection

  :config
  (evil-mode 1)

  (general-define-key
   :keymaps 'evil-window-map
   "u" 'winner-undo
   "C-r" 'winner-redo

   "C-h" 'evil-window-left
   "C-j" 'evil-window-down
   "C-l" 'evil-window-right
   "C-k" 'evil-window-up

   "M-h" 'buf-move-left
   "M-j" 'buf-move-down
   "M-l" 'buf-move-right
   "M-k" 'buf-move-up)

  ;; Set initial states for specific modes
  (dolist (mode-state '((inferior-emacs-lisp-mode . emacs)
                        (calendar-mode            . emacs)
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
  (evil-collection-init 'calendar)
  (evil-collection-init 'consult)
  (evil-collection-init 'corfu)
  (evil-collection-init 'dashboard)
  (evil-collection-init 'dired)
  (evil-collection-init 'eat)
  (evil-collection-init 'ediff)
  (evil-collection-init 'eglot)
  (evil-collection-init 'embark)
  (evil-collection-init 'eshell)
  (evil-collection-init 'help)
  (evil-collection-init 'info)
  (evil-collection-init 'magit)
  (evil-collection-init 'org))

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
