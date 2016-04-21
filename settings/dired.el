(setq dired-listing-switches "-alh"
      dired-omit-files "^\\.?#\\|^\\.$\\|^\\.DS_Store$"
      dired-recursive-copies 'always
      dired-recursive-deletes 'always)

(define-key dired-mode-map (kbd "SPC") nil)

(use-package dired+
  :config
  (diredp-toggle-find-file-reuse-dir t))
