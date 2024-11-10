(use-package dired
  :ensure nil
  :commands (dired dired-jump)

  :custom
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alh")
  (dired-omit-files "^\\.?#\\|^\\.$\\|\\.DS_Store$\\|\\.gitkeep$")
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)

  :bind
  (:map dired-mode-map
        ("SPC" . nil)))
