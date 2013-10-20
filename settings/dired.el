(require-package 'dired+)

(require 'dired)

(setq dired-listing-switches "-alh"
      dired-omit-files "^\\.?#\\|^\\.$\\|^\\.DS_Store$"
      dired-recursive-copies 'always
      dired-recursive-deletes 'always)

;; set SPC to nil before evil makes dired-mode-map the overriding map
(define-key dired-mode-map (kbd "SPC") nil)

(diredp-toggle-find-file-reuse-dir t)
