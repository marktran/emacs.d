(defvar recentf-auto-save-timer nil
  "Idle timer used to save the recent file list.")

(use-package recentf
  :ensure nil

  :preface
  (defun m/recentf-save-list-silently ()
    "Save the recent file list without displaying minibuffer messages."
    (let ((inhibit-message t))
      (recentf-save-list)))

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
  (when (timerp (bound-and-true-p recentf-auto-save-timer))
    (cancel-timer recentf-auto-save-timer))
  (setq recentf-auto-save-timer
        (run-with-idle-timer 600 t #'m/recentf-save-list-silently))
  (recentf-mode 1))
