(use-package whitespace-cleanup-mode
  :ensure t
  :diminish whitespace-cleanup-mode

  :config
  (setq-default show-trailing-whitespace nil)
  (global-whitespace-cleanup-mode t)

  (add-hook 'before-save-hook 'whitespace-cleanup))
