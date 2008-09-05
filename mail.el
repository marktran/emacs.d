;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mail.el : Mark Tran <mark@nirv.net>

(defun mutt-mail-mode-hook ()
  (turn-on-auto-fill)
  (flush-lines "^\\(> \n\\)*> -- \n\\(\n?> .*\\)*") 
  (not-modified)
  (mail-text))

(add-to-list 'auto-mode-alist '("\\mutt.*" . mail-mode))
(add-hook 'mail-mode-hook 'mutt-mail-mode-hook)

(provide 'mail)
