(use-package treemacs
  :config
  (use-package treemacs-evil)
  (use-package treemacs-projectile)

  (setq treemacs-follow-after-init t
        treemacs-git-integration t)

  (treemacs-follow-mode 1))
