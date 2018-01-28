(use-package evil
  :init
  (setq evil-ex-search-vim-style-regexp t
        evil-mode-line-format nil
        evil-search-module 'evil-search
        evil-symbol-word-search t
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t)
  (setq-default evil-shift-width 2)

  (evil-mode 1)

  :config
  (use-package evil-escape
    :diminish evil-escape-mode

    :config
    (evil-escape-mode 1)

    (setq-default evil-escape-key-sequence "jk"))

  (use-package evil-iedit-state
    :commands evil-iedit-state/iedit-mode)

  (use-package evil-lion
    :config
    (evil-lion-mode 1))

  (use-package evil-matchit
    :init
    (global-evil-matchit-mode 1))

  (use-package evil-nerd-commenter
    :commands evilnc-comment-or-uncomment-lines)

  (use-package evil-numbers
    :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-t))

  (use-package evil-surround
    :init
    (global-evil-surround-mode 1))

  (loop for (mode . state) in '((inferior-emacs-lisp-mode . emacs)
                                (comint-mode              . emacs)
                                (eshell-mode              . emacs)
                                (occur-mode               . emacs)
                                (org-mode                 . normal)
                                (paradox-menu-mode        . emacs)
                                (special-mode             . normal)
                                (sql-interactive-mode     . emacs)
                                (text-mode                . emacs))
        do (evil-set-initial-state mode state)))
