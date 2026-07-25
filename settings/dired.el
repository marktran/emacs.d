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

  :custom
  ;; ignoramus puts dired-omit-mode on every dired buffer, and each
  ;; readin/revert then reports "(Nothing to omit)" or "Omitting...",
  ;; clobbering more useful echo-area messages (auto-revert makes this
  ;; chronic in ready-player's playback dired buffer).
  (dired-omit-verbose nil)

  :config
  (defun diminish-dired-omit-mode ()
    "Diminish dired-omit-mode in the mode line."
    (diminish 'dired-omit-mode))

  (advice-add 'dired-omit-startup :after #'diminish-dired-omit-mode))
