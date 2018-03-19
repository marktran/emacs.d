(use-package dired
  :ensure nil
  :commands dired-jump

  :bind
  (:map dired-mode-map
        ("SPC" . nil))

  :config
  (setq dired-listing-switches "-alh"
        dired-omit-files "^\\.?#\\|^\\.$\\|\\.DS_Store$\\|\\.gitkeep$"
        dired-recursive-copies 'always
        dired-recursive-deletes 'always))

(use-package dired+
  :ensure nil
  :after dired
  :config (diredp-toggle-find-file-reuse-dir t))
