(use-package treemacs
  :ensure t
  :commands (treemacs treemacs-select-window treemacs-add-and-display-current-project-exclusively)

  :custom
  (treemacs-file-event-delay 5000)
  (treemacs-file-follow-delay 0.2)
  (treemacs-follow-after-init t)
  (treemacs-git-integration t)

  :config
  (treemacs-filewatch-mode 1)
  (treemacs-follow-mode 1))

(use-package treemacs-evil
  :ensure t
  :after (treemacs evil))
