(use-package recentf
  :config
  (recentf-mode)

  (add-to-list 'recentf-exclude (expand-file-name package-user-dir))
  (add-to-list 'recentf-exclude "TAGS")

  (setq recentf-auto-cleanup 'never
        recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list)
        recentf-max-saved-items 100))
