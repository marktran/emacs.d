(defun toggle-calendar ()
  (interactive)
  (let ((calendar-window (get-buffer-window "*Calendar*")))
    (if calendar-window
        (delete-window calendar-window)
      (calendar))))
