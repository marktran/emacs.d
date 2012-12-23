(setq auto-save-default nil
      comment-auto-fill-only-comments t
      confirm-nonexistent-file-or-buffer nil
      disabled-command-function nil
      display-time-24hr-format t
      display-time-default-load-average nil
      history-length 250
      initial-scratch-message nil
      isearch-lazy-highlight nil
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function
                                        kill-buffer-query-functions)
      require-final-newline nil
      vc-handled-backends '(git))

(setq-default c-basic-offset 4
              fill-column 72
              indent-tabs-mode nil
              tab-width 4
              truncate-lines t)

(c-set-offset 'case-label '+)
(fset 'yes-or-no-p 'y-or-n-p)

(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; load ~/.emacs.d/settings
(mapc 'load (directory-files "~/.emacs.d/settings" t "^[A-Za-z]*\\.el"))
