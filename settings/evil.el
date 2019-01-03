(use-package evil
  :init
  (setq evil-ex-search-vim-style-regexp t
        evil-mode-line-format nil
        evil-search-module 'evil-search
        evil-symbol-word-search t
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-want-keybinding nil)
  (setq-default evil-shift-width 2)

  (evil-mode 1)

  :config
  (loop for (mode . state) in '((inferior-emacs-lisp-mode . emacs)
                                (comint-mode              . emacs)
                                (eshell-mode              . emacs)
                                (occur-mode               . emacs)
                                (org-mode                 . normal)
                                (paradox-menu-mode        . emacs)
                                (special-mode             . normal)
                                (sql-interactive-mode     . emacs)
                                (text-mode                . emacs)
                                (vue-mode                 . normal)
                                (yaml-mode                . normal))
        do (evil-set-initial-state mode state)))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init 'dired)
  (evil-collection-init 'ediff)
  (evil-collection-init 'ivy))

(use-package evil-escape
  :after evil
  :diminish evil-escape-mode

  :config
  (evil-escape-mode 1)

  (setq-default evil-escape-key-sequence "jk"))

(use-package evil-iedit-state
  :after evil
  :commands evil-iedit-state/iedit-mode)

(use-package evil-lion
  :after evil
  :config
  (evil-lion-mode 1))

(use-package evil-matchit
  :after evil
  :init
  (global-evil-matchit-mode 1))

(use-package evil-nerd-commenter
  :after evil
  :commands evilnc-comment-or-uncomment-lines)

(use-package evil-numbers
  :after evil
  :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-t))

(use-package evil-surround
  :after evil
  :init
  (global-evil-surround-mode 1))

(evil-collection-init 'evil-dired)
