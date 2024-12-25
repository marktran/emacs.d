(setq auto-save-default nil
      comment-auto-fill-only-comments t
      confirm-nonexistent-file-or-buffer nil
      custom-file "~/.emacs.d/custom.el"
      delete-selection-mode 1
      disabled-command-function nil
      global-auto-revert-non-file-buffers t
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function
                                        kill-buffer-query-functions))

(setq-default c-basic-offset 4
              fill-column 72
              indent-tabs-mode nil
              tab-width 2
              truncate-lines t)

(c-set-offset 'case-label '+)
(if (boundp 'use-short-answers)
    (setq use-short-answers t)
  (fset 'yes-or-no-p 'y-or-n-p))

(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; load ~/.emacs.d/settings
(mapc 'load (directory-files "~/.emacs.d/settings" t "^[A-Za-z-]*\\.el"))
