(use-package treemacs
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))

  :config
  (setq treemacs-file-event-delay 5000
        treemacs-file-follow-delay 0.2
        treemacs-follow-after-init t
        treemacs-git-integration t)

  (treemacs-filewatch-mode 1)
  (treemacs-follow-mode 1))

(use-package treemacs-evil
  :after treemacs evil)

(use-package treemacs-projectile
  :after treemacs projectile)
