(defvar denote-journal--origin-window nil
  "The window from which the calendar was opened.")

(defun toggle-calendar ()
  (interactive)
  (let ((calendar-window (get-buffer-window "*Calendar*")))
    (if calendar-window
        (delete-window calendar-window)
      (setq denote-journal--origin-window (selected-window))
      (calendar))))
