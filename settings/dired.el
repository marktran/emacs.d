(use-package dired
  :ensure nil

  :custom
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-AFhlv")
  (dired-omit-files "^\\.?#\\|^\\.$\\|\\.DS_Store$\\|\\.gitkeep$")
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always)

  :general
  (:keymaps 'dired-mode-map
   :states 'normal
   "DEL" 'dired-up-directory
   "SPC" 'general-prefix-map))

(use-package dired-x
  :ensure nil
  :after dired

  :diminish dired-omit-mode

  :config
  (defun diminish-dired-omit-mode ()
    "Diminish dired-omit-mode in the mode line."
    (diminish 'dired-omit-mode))

  (advice-add 'dired-omit-startup :after #'diminish-dired-omit-mode))
