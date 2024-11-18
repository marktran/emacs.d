(use-package whitespace-cleanup-mode
  :ensure t
  :diminish whitespace-cleanup-mode

  :custom
  (show-trailing-whitespace nil)

  :hook
  (before-save . whitespace-clean)

  :config
  (whitespace-cleanup-mode 1))
