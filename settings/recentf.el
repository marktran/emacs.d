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
  ;; `recentf-filename-handlers' records true names (~/.emacs.d is a
  ;; symlink into the repo), so directory exclusions must be true
  ;; names as well. The no-littering trees keep package state like
  ;; the EMMS history out of the recent files list.
  (recentf-exclude (list (file-truename package-user-dir)
                         #'ignoramus-boring-p
                         ".bookmarks"
                         "recentf"
                         "TAGS"
                         (file-truename no-littering-var-directory)
                         (file-truename no-littering-etc-directory)))
  (recentf-keep '(file-remote-p))
  (recentf-max-saved-items 150)
  (recentf-filename-handlers '(file-truename))  ;; Resolve symlinks

  :config
  (when (timerp (bound-and-true-p recentf-auto-save-timer))
    (cancel-timer recentf-auto-save-timer))
  (setq recentf-auto-save-timer
        (run-with-idle-timer 600 t #'m/recentf-save-list-silently))
  (recentf-mode 1))
