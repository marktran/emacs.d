(use-package eshell
  :commands eshell

  :config
  (setq eshell-aliases-file "~/.emacs.d/eshell/alias"
        eshell-banner-message ""
        eshell-cmpl-cycle-completions nil
        eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'"
        eshell-highlight-prompt nil
        eshell-history-size 4096
        eshell-last-dir-ring-size 10
        eshell-list-files-after-cd t
        eshell-prompt-function
        (lambda ()
          (concat
           (propertize (host-name) 'face `(:foreground "#cf6a4c"))
           " "
           (propertize (abbreviate-file-name (eshell/pwd)) 'face `(:foreground "#cd00cd"))
           " "))
        eshell-prompt-regexp "^[^ ]* [^ ]* "
        esehll-review-quick-commands t
        eshell-smart-space-goes-to-end t
        eshell-where-to-jump 'begin))
