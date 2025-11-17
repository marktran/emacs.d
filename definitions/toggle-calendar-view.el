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
(defvar-local calendar-view-mode '3-month
  "Current calendar view mode, either '3-month or '12-month.")

;;; Helper functions
(defun calendar--calculate-column-position (col-num)
  "Calculate the starting column position for column COL-NUM (0, 1, or 2)."
  (+ calendar-month-left-margin (* col-num calendar-month-column-width)))

(defun calendar--generate-month-at-column (month year col)
  "Generate a calendar for MONTH and YEAR at column position COL (0, 1, or 2)."
  (calendar-generate-month month year (calendar--calculate-column-position col)))

(defun calendar--mark-date-in-month-with-face (day month-index face)
  "Mark DAY in the month at MONTH-INDEX (0-11) with FACE."
  (let* ((inhibit-read-only t)
         (row (/ month-index 3))
         (col (mod month-index 3))
         (row-start-line (* row calendar-row-height))
         (col-start (calendar--calculate-column-position col))
         (col-end (+ col-start calendar-month-content-width)))
    (save-excursion
      (goto-char (point-min))
      (forward-line row-start-line)
      ;; Skip past month name and day headers (2 lines)
      (forward-line 2)
      ;; Search for the day within this month's area
      (let ((search-limit (+ row-start-line calendar-row-height))
            (current-line (+ row-start-line 2)))
        (while (and (< current-line search-limit) (not (eobp)))
          (move-to-column col-start)
          (let ((line-start (point)))
            (move-to-column col-end)
            (let ((line-end (point)))
              (goto-char line-start)
              (when (re-search-forward (format "\\b%d\\b" day) line-end t)
                (put-text-property (match-beginning 0) (match-end 0)
                                   'face face))))
          (forward-line 1)
          (setq current-line (1+ current-line)))))))

(defun calendar--mark-date-in-month (day month-index)
  "Mark DAY in the month at MONTH-INDEX (0-11) with holiday face."
  (calendar--mark-date-in-month-with-face day month-index 'holiday))

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
      (set-buffer-modified-p nil))
    (pop-to-buffer calendar-buffer)))

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
        ;; Mark holidays for all 12 months
        (dotimes (i 12)
          (let* ((m base-month)
                 (y base-year))
            (calendar-increment-month m y i)
            ;; Bind displayed-month and displayed-year for holiday functions
            (let ((displayed-month m)
                  (displayed-year y))
              ;; Compute holidays for this month by evaluating calendar-holidays
              (dolist (holiday-descriptor calendar-holidays)
                (let ((holiday-dates (eval holiday-descriptor)))
                  (when holiday-dates
                    (dolist (holiday holiday-dates)
                      (let* ((date (car holiday))
                             (day (calendar-extract-day date))
                             (hmonth (calendar-extract-month date)))
                        (when (= hmonth m)
                          (calendar--mark-date-in-month day i))))))))))
        ;; Mark today's date
        (let* ((today (calendar-current-date))
               (today-day (calendar-extract-day today))
               (today-month (calendar-extract-month today))
               (today-year (calendar-extract-year today)))
          (dotimes (i 12)
            (let* ((m base-month)
                   (y base-year))
              (calendar-increment-month m y i)
              (when (and (= m today-month) (= y today-year))
                (calendar--mark-date-in-month-with-face today-day i 'calendar-today)))))
        (set-buffer-modified-p nil)))
    (pop-to-buffer calendar-buffer)))

(defun toggle-calendar-view ()
  "Toggle between 3-month and 12-month calendar views.
When switching to 12-month view, delete other windows to provide
more space for the larger calendar display."
  (interactive)
  (let ((cal-buf (get-buffer calendar-buffer)))
    (when cal-buf
      (with-current-buffer cal-buf
        (if (eq calendar-view-mode '3-month)
            (progn
              (setq calendar-view-mode '12-month)
              (calendar-regenerate-12-month))
          (setq calendar-view-mode '3-month)
          (calendar-regenerate-3-month))))))

(defun calendar-12-month ()
  "Display a 12-month calendar view."
  (interactive)
  (require 'calendar)
  (calendar)
  (setq calendar-view-mode '12-month)
  (calendar-regenerate-12-month))
