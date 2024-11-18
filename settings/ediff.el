(use-package ediff
  :ensure nil

  :custom
  (ediff-split-window-function 'split-window-horizontally)
  (ediff-window-setup-function 'ediff-setup-windows-plain)

  :hook
  (ediff-cleanup . ediff-janitor))
