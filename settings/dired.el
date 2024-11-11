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

(use-package dired-x
  :after dired
  :ensure nil
  :diminish dired-omit-mode
  :config
  (defun diminish-dired-omit-mode ()
    "Diminish dired-omit-mode in the mode line."
    (diminish 'dired-omit-mode))

  (advice-add 'dired-omit-startup :after #'diminish-dired-omit-mode))
