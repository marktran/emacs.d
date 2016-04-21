(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode

  :config
  (setq-default show-trailing-whitespace nil)
  (global-whitespace-cleanup-mode t)

  (add-hook 'before-save-hook 'whitespace-cleanup))
