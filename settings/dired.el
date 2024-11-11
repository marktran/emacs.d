(use-package dired
  :ensure nil
  :commands (dired dired-jump)

  :custom
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alhF")
  (dired-omit-files "^\\.?#\\|^\\.$\\|\\.DS_Store$\\|\\.gitkeep$")
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)

  :general
  (:keymaps 'dired-mode-map
   :states 'normal
   "DEL" 'dired-up-directory
   "SPC" 'general-prefix-map))
