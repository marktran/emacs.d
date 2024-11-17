(use-package auto-package-update
  :custom
  (auto-package-update-at-startup nil)
  (auto-package-update-interval 7)
  (auto-package-update-prompt-before-update t)
  (auto-package-update-hide-results nil)

  :config
  (auto-package-update-at-time "09:00"))
