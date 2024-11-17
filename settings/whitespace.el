(use-package whitespace-cleanup-mode
  :diminish whitespace-cleanup-mode

  :hook
  (before-save . whitespace-clean)

  :custom
  (show-trailing-whitespace nil))
