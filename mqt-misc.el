;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d-misc.el : Mark Tran <mark@nirv.net>

;; settings
(setq comment-auto-fill-only-comments t
      backup-inhibited t
      disabled-command-function nil
      gnus-home-directory "~/.gnus.d/"
      gnus-init-file "~/.emacs.d/.gnus.el"
      history-length 250
      require-final-newline t
      tab-width 4
      tramp-default-method "ssh")

(setq-default c-basic-offset 4
              fill-column 72
              indent-tabs-mode nil)

(fset 'yes-or-no-p 'y-or-n-p)

;; hooks
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

(provide 'mqt-misc)
