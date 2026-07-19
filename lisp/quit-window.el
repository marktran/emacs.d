;; http://superuser.com/questions/397806/emacs-modify-quit-window-to-delete-buffer-not-just-bury-it
(defun quit-window-always-kill (args)
  "When running `quit-window', always kill the buffer."
  (cons t (cdr args)))

(advice-add 'quit-window :filter-args #'quit-window-always-kill)
