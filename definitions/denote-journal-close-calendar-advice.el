(defun denote-journal-close-calendar-advice (&rest _)
  "Close the calendar window after opening a journal entry."
  (let ((calendar-window (get-buffer-window "*Calendar*")))
    (when calendar-window
      (delete-window calendar-window))))

(advice-add 'denote-journal-calendar-new-or-existing :after #'denote-journal-close-calendar-advice)
