(use-package dired
  :ensure nil
  :commands dired-jump

  :bind
  (:map dired-mode-map
        ("SPC" . nil))

  :config
  (use-package dired+ :config (diredp-toggle-find-file-reuse-dir t))

  (setq dired-listing-switches "-alh"
        dired-omit-files "^\\.?#\\|^\\.$\\|\\.DS_Store$\\|\\.gitkeep$"
        dired-recursive-copies 'always
        dired-recursive-deletes 'always))
