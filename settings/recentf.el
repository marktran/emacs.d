(use-package recentf
  :ensure nil

  :custom
  (recentf-auto-cleanup 'never)
  (recentf-exclude (list (expand-file-name package-user-dir)
                         #'ignoramus-boring-p
                         ".bookmarks"
                         "recentf"
                         "TAGS"))
  (recentf-keep '(file-remote-p))
  (recentf-max-saved-items 150)
  (recentf-filename-handlers '(file-truename))  ;; Resolve symlinks

  :config
  (setq recentf-auto-save-timer
        (run-with-idle-timer 600 t #'recentf-save-list))
  (recentf-mode 1))
