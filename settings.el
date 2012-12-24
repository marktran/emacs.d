(setq auto-save-default nil
      comment-auto-fill-only-comments t
      confirm-nonexistent-file-or-buffer nil
      disabled-command-function nil
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function
                                        kill-buffer-query-functions)
      require-final-newline nil)

(setq-default c-basic-offset 4
              fill-column 72
              indent-tabs-mode nil
              tab-width 2
              truncate-lines t)

(c-set-offset 'case-label '+)
(fset 'yes-or-no-p 'y-or-n-p)

;; load ~/.emacs.d/settings
(mapc 'load (directory-files "~/.emacs.d/settings" t "^[A-Za-z]*\\.el"))
