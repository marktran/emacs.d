(use-package files
  :ensure nil

  :init
  (make-directory "~/.emacs.d/backups" t)

  :custom
  (backup-by-copying t)
  (backup-directory-alist '(("." . "~/.emacs.d/backups"))))
