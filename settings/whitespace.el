(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode
  :commands whitespace-cleanup

  :config
  (setq-default show-trailing-whitespace nil)

  (add-hook 'before-save-hook 'whitespace-cleanup))
