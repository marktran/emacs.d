(use-package project-explorer
  :commands (project-explorer-open)
  :config
  (setq pe/omit-regex "^\\.\\|^#\\|~$|^vendor$")

  (define-key project-explorer-mode-map (kbd "C-w h") 'windmove-left)
  (define-key project-explorer-mode-map (kbd "C-w C-h") 'windmove-left)
  (define-key project-explorer-mode-map (kbd "C-w l") 'windmove-right)
  (define-key project-explorer-mode-map (kbd "C-w C-l") 'windmove-right)

  (evil-set-initial-state 'project-explorer-mode 'emacs))
