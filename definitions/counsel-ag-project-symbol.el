(defun counsel-ag-project-symbol ()
  (interactive)
  (counsel-ag (thing-at-point 'symbol) (projectile-project-root)))
