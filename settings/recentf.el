(use-package recentf
  :init
  (recentf-mode)

  :config
  (setq recentf-auto-cleanup 'never
        recentf-auto-save-timer (run-with-idle-timer 600 t 'recentf-save-list)

        recentf-exclude (list (expand-file-name package-user-dir)
                              #'ignoramus-boring-p
                              ".bookmarks"
                              "ido.last"
                              "recentf"
                              "TAGS")

        recentf-max-saved-items 150))
