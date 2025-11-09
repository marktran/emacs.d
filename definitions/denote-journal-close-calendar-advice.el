(defun denote-journal-close-calendar-advice (orig-fun &rest args)
  "Open journal in origin window and close calendar popup."
  (let ((calendar-window (get-buffer-window "*Calendar*")))
    (apply orig-fun args)
    (let ((journal-buffer (current-buffer)))
      (when (and denote-journal--origin-window
                 (window-live-p denote-journal--origin-window))
        (select-window denote-journal--origin-window)
        (switch-to-buffer journal-buffer))
      (delete-other-windows)
      (when (and calendar-window (window-live-p calendar-window))
        (delete-window calendar-window)))))

(advice-add 'denote-journal-calendar-new-or-existing :around #'denote-journal-close-calendar-advice)
