;;; Layout constants
(defconst calendar-month-column-width 25
  "Width of each month column in the calendar display.")

(defconst calendar-month-left-margin 5
  "Left margin before the first month column.")

(defconst calendar-month-content-width 20
  "Width of the content area within a month column.")

(defconst calendar-row-height 10
  "Number of lines per row in the 12-month grid view.")

(defconst calendar-search-region-size 200
  "Size of region to search when highlighting today's date.")

(defconst calendar-column-boundary-1 20
  "Column position boundary between columns 0 and 1.")

(defconst calendar-column-boundary-2 45
  "Column position boundary between columns 1 and 2.")

;;; State variable
(defvar calendar-view-mode '3-month
  "Current calendar view mode, either '3-month or '12-month.")

;;; Helper functions
(defun calendar--calculate-column-position (col-num)
  "Calculate the starting column position for column COL-NUM (0, 1, or 2)."
  (+ calendar-month-left-margin (* col-num calendar-month-column-width)))

(defun calendar--generate-month-at-column (month year col)
  "Generate a calendar for MONTH and YEAR at column position COL (0, 1, or 2)."
  (calendar-generate-month month year (calendar--calculate-column-position col)))

(defun calendar--highlight-today-in-buffer ()
  "Search the calendar buffer and highlight today's date."
  (let* ((today (calendar-current-date))
         (today-day (calendar-extract-day today))
         (today-month (calendar-extract-month today))
         (today-year (calendar-extract-year today))
         (month-name (calendar-month-name today-month))
         (inhibit-read-only t))
    (goto-char (point-min))
    (let ((found-positions '())
          (highlighted nil))
      (while (re-search-forward (regexp-quote month-name) nil t)
        (push (match-beginning 0) found-positions))
      (dolist (pos (nreverse found-positions))
        (unless highlighted
          (save-excursion
            (goto-char pos)
            (let* ((month-col (current-column))
                   ;; Determine which column (0, 1, or 2) based on horizontal position
                   (col-num (cond
                             ((< month-col calendar-column-boundary-1) 0)
                             ((< month-col calendar-column-boundary-2) 1)
                             (t 2)))
                   (col-start (calendar--calculate-column-position col-num))
                   (col-end (+ col-start calendar-month-content-width)))
              ;; Skip month name and day-of-week headers to reach date grid
              (forward-line 2)
              (let ((region-end (+ (point) calendar-search-region-size)))
                (while (and (not highlighted) (< (point) region-end) (not (eobp)))
                  (move-to-column col-start)
                  (let ((line-start (point)))
                    (move-to-column col-end)
                    (let ((line-end (point)))
                      (goto-char line-start)
                      (when (re-search-forward (format "\\b%d\\b" today-day) line-end t)
                        (put-text-property (match-beginning 0) (match-end 0)
                                           'face 'calendar-today)
                        (setq highlighted t))))
                  (forward-line 1))))))))))

(defun calendar-regenerate-3-month ()
  "Regenerate the calendar buffer with 3-month view.
Reuses the existing calendar buffer for efficiency."
  (interactive)
  (let* ((inhibit-read-only t)
         (date (calendar-current-date))
         (month (calendar-extract-month date))
         (year (calendar-extract-year date)))
    (with-current-buffer (get-buffer calendar-buffer)
      (erase-buffer)
      (calendar-increment-month month year -1)
      (dotimes (i 3)
        (calendar--generate-month-at-column month year i)
        (calendar-increment-month month year 1))
      (goto-char (point-min))
      (set-buffer-modified-p nil))))

(defun calendar-regenerate-12-month ()
  "Regenerate the calendar buffer with 12-month view in a 4×3 grid.
Kills and recreates the calendar buffer to ensure the narrow/widen
technique works correctly for laying out the 4×3 grid."
  (interactive)
  (let* ((date (calendar-current-date))
         (base-month (calendar-extract-month date))
         (base-year (calendar-extract-year date)))
    (calendar-increment-month base-month base-year -5)
    (when (get-buffer calendar-buffer)
      (kill-buffer calendar-buffer))
    (get-buffer-create calendar-buffer)
    (with-current-buffer calendar-buffer
      (calendar-mode)
      (setq displayed-month base-month)
      (setq displayed-year base-year)
      (let ((inhibit-read-only t))
        (erase-buffer)
        ;; Generate 4 rows of 3 months using narrow/widen for row positioning
        (dotimes (row 4)
          (dotimes (col 3)
            (let ((m base-month)
                  (y base-year))
              (calendar-increment-month m y (+ (* row 3) col))
              (calendar--generate-month-at-column m y col)))
          ;; Pad to row height and narrow to end for next row
          (goto-char (point-max))
          (insert (make-string (- calendar-row-height (count-lines (point-min) (point-max))) ?\n))
          (widen)
          (goto-char (point-max))
          (narrow-to-region (point-max) (point-max)))
        (widen)
        (goto-char (point-min))
        (set-buffer-modified-p nil))
      (calendar--highlight-today-in-buffer))
    (display-buffer calendar-buffer)))

(defun toggle-calendar-view ()
  "Toggle between 3-month and 12-month calendar views.
When switching to 12-month view, delete other windows to provide
more space for the larger calendar display."
  (interactive)
  (if (eq calendar-view-mode '3-month)
      (let ((win (selected-window)))
        (setq calendar-view-mode '12-month)
        (delete-other-windows)
        (calendar-regenerate-12-month)
        (select-window win))
    (setq calendar-view-mode '3-month)
    (calendar-regenerate-3-month)))

(defun calendar-12-month ()
  "Display a 12-month calendar view."
  (interactive)
  (require 'calendar)
  (calendar)
  (setq calendar-view-mode '12-month)
  (calendar-regenerate-12-month))

(with-eval-after-load 'calendar
  (with-eval-after-load 'general
    (general-define-key
     :states '(emacs normal)
     :keymaps 'calendar-mode-map
     "<tab>" 'toggle-calendar-view)))
