
(defun m/org-insert-todo-heading ()
  (interactive)
  (end-of-line)
  (org-insert-todo-heading nil)
  (evil-insert 1))
