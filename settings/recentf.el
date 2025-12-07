(use-package recentf
  :ensure nil

  :custom
  (recentf-auto-cleanup 'never)
  (recentf-exclude (list (expand-file-name package-user-dir)
                         #'ignoramus-boring-p
                         ".bookmarks"
                         "recentf"
                         "TAGS"))
  (recentf-keep '(file-remote-p file-readable-p))
  (recentf-max-saved-items 15)
  (recentf-filename-handlers '(file-truename))  ;; Resolve symlinks

  :config
  (recentf-mode 1))
