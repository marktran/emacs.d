(use-package treemacs
  :ensure t

  :custom
  (treemacs-file-event-delay 5000)
  (treemacs-file-follow-delay 0.2)
  (treemacs-follow-after-init t)
  (treemacs-git-integration t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-follow-mode 1))

(use-package treemacs-evil
  :after (treemacs evil))
