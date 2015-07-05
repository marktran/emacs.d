(use-package recentf
  :defer t

  :init
  (add-to-list 'recentf-exclude (expand-file-name package-user-dir))
  (add-to-list 'recentf-exclude "TAGS")

  :config
  (setq recentf-auto-cleanup 'never
        recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list)
        recentf-max-saved-items 100))
