(use-package recentf
  :custom
  (recentf-auto-cleanup 'never)
  (recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list))
  (recentf-exclude (list (expand-file-name package-user-dir)
                         #'ignoramus-boring-p
                         ".bookmarks"
                         "recentf"
                         "TAGS"))
  (recentf-keep '(file-remote-p file-readable-p))
  (recentf-max-saved-items 150)
  (recentf-filename-handlers '(file-truename))  ;; Resolve symlinks

  :init
  (recentf-mode))
