;;; toggle-calendar-view.el --- Toggle 3/12 month calendar views

(require 'calendar)
(require 'holidays)

;; Calendar internals we intentionally set when regenerating views.
(defvar displayed-month)
(defvar displayed-year)

(defvar calendar--window-configuration-before-12-month nil
  "Saved window configuration before expanding to 12-month calendar view.")

;;; Layout constants
(defconst calendar-month-column-width 25
  "Width of each month column in the calendar display.")

(defconst calendar-month-left-margin 5
  "Left margin before the first month column.")

(defconst calendar-month-content-width 20
  "Width of the content area within a month column.")

(defconst calendar-row-height 10
  "Number of lines per row in the 12-month grid view.")

;;; State variable
(defvar-local calendar-view-mode '3-month
  "Current calendar view mode, either `3-month' or `12-month'.")

;; Shared with denote journal calendar advice.
(defvar denote-journal--origin-window)

;;; Helper functions
(defun calendar--calculate-column-position (col-num)
  "Calculate the starting column position for column COL-NUM (0, 1, or 2)."
  (+ calendar-month-left-margin (* col-num calendar-month-column-width)))

(defun calendar--generate-month-at-column (month year col)
  "Generate a calendar for MONTH and YEAR at column position COL (0, 1, or 2)."
  (calendar-generate-month month year (calendar--calculate-column-position col)))

(defun calendar--mark-date-in-month (day month-index face)
  "Mark DAY in the month at MONTH-INDEX (0-11) with FACE."
  (let* ((inhibit-read-only t)
         (row (/ month-index 3))
         (col (mod month-index 3))
         ;; Each rendered row advances by one fewer line than
         ;; `calendar-row-height` in this layout.
         (row-step (1- calendar-row-height))
         (row-start-line (* row row-step))
         (col-start (calendar--calculate-column-position col))
         (col-end (+ col-start calendar-month-content-width)))
    (save-excursion
      (goto-char (point-min))
      ;; Skip past month name and day headers (2 lines).
      (forward-line (+ row-start-line 2))
      ;; Search for the day within this month's column.
      (dotimes (_ (- row-step 2))
        (unless (eobp)
          (move-to-column col-start)
          (let ((line-start (point)))
            (move-to-column col-end)
            (let ((line-end (point)))
              (goto-char line-start)
              (when (re-search-forward (format "\\b%d\\b" day) line-end t)
                (put-text-property (match-beginning 0) (match-end 0)
                                   'face face))))
          (forward-line 1))))))

(defun calendar--mark-holidays-and-today (start-month start-year month-count)
  "Mark holidays and today from START-MONTH/START-YEAR across MONTH-COUNT months."
  (let* ((today (calendar-current-date))
         (today-day (calendar-extract-day today))
         (today-month (calendar-extract-month today))
         (today-year (calendar-extract-year today)))
    (dotimes (i month-count)
      (let ((m start-month)
            (y start-year))
        (calendar-increment-month m y i)
        ;; `calendar-holiday-list' evaluates `calendar-holidays' relative to
        ;; the dynamically bound displayed month and year.
        (let ((displayed-month m)
              (displayed-year y))
          (dolist (holiday (calendar-holiday-list))
            (let ((date (car holiday)))
              (when (= (calendar-extract-month date) m)
                (calendar--mark-date-in-month (calendar-extract-day date)
                                              i 'holiday)))))
        ;; Mark today last so its face wins if it is also a holiday.
        (when (and (= m today-month) (= y today-year))
          (calendar--mark-date-in-month today-day i 'calendar-today))))))

(defun calendar--window ()
  "Return the live window displaying the calendar buffer, if any."
  (let ((window (get-buffer-window calendar-buffer t)))
    (and (window-live-p window) window)))

(defun calendar--maximize-window-if-possible ()
  "Delete other windows for the calendar buffer when safe to do so.
Side windows cannot be made the only window, so skip in that case."
  (let ((window (calendar--window)))
    (when (and window (not (window-parameter window 'window-side)))
      (setq calendar--window-configuration-before-12-month
            (current-window-configuration))
      (with-selected-window window
        (delete-other-windows window)))))

(defun calendar--expand-side-window-for-12-month ()
  "Grow calendar side window enough to display the 12-month grid."
  (let ((window (calendar--window)))
    (when (and window (window-parameter window 'window-side))
      (with-selected-window window
        (let* ((desired-height (+ (* 4 calendar-row-height) 1))
               (max-height (max 10 (- (frame-height) 2)))
               (min-height (min desired-height max-height)))
          (fit-window-to-buffer window max-height min-height))))))

(defun calendar--restore-window-layout-if-available ()
  "Restore window layout saved before 12-month expansion.
If no layout is saved, shrink the calendar window to fit 3-month view."
  (if (window-configuration-p calendar--window-configuration-before-12-month)
      (progn
        (set-window-configuration calendar--window-configuration-before-12-month)
        (setq calendar--window-configuration-before-12-month nil))
    (let ((window (calendar--window)))
      (when window
        (with-selected-window window
          (fit-window-to-buffer window (+ calendar-row-height 2) 8))))))

(defun calendar-regenerate-3-month ()
  "Regenerate the calendar buffer with 3-month view.
Reuses the existing calendar buffer for efficiency."
  (interactive)
  (let* ((date (calendar-current-date))
         (month (calendar-extract-month date))
         (year (calendar-extract-year date))
         (start-month month)
         (start-year year))
    ;; Show last month, this month, and next month.
    (calendar-increment-month start-month start-year -1)
    (with-current-buffer (get-buffer-create calendar-buffer)
      (calendar-mode)
      (setq-local calendar-view-mode '3-month)
      (setq displayed-month month
            displayed-year year)
      (let ((inhibit-read-only t)
            (m start-month)
            (y start-year))
        (erase-buffer)
        (dotimes (i 3)
          (calendar--generate-month-at-column m y i)
          (calendar-increment-month m y 1))
        (calendar--mark-holidays-and-today start-month start-year 3)
        (goto-char (point-min))
        (set-buffer-modified-p nil)))
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
    (with-current-buffer (get-buffer-create calendar-buffer)
      (calendar-mode)
      (setq-local calendar-view-mode '12-month)
      (setq displayed-month base-month
            displayed-year base-year)
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
        (calendar--mark-holidays-and-today base-month base-year 12)
        (set-buffer-modified-p nil)))
    (pop-to-buffer calendar-buffer)))

(defun calendar--show-12-month ()
  "Switch the calendar buffer to 12-month view and enlarge its window.
Tries to delete other windows to provide more space for the larger
calendar display."
  (calendar-regenerate-12-month)
  (calendar--maximize-window-if-possible)
  (calendar--expand-side-window-for-12-month))

(defun calendar--show-3-month ()
  "Switch the calendar buffer to 3-month view and restore the window layout."
  (calendar-regenerate-3-month)
  (calendar--restore-window-layout-if-available))

(defun toggle-calendar-view ()
  "Toggle between 3-month and 12-month calendar views."
  (interactive)
  (let ((cal-buf (get-buffer calendar-buffer)))
    (when cal-buf
      (if (eq (buffer-local-value 'calendar-view-mode cal-buf) '3-month)
          (calendar--show-12-month)
        (calendar--show-3-month)))))

(defun calendar-12-month ()
  "Display a 12-month calendar view."
  (interactive)
  (calendar)
  (calendar--show-12-month))

(defun toggle-calendar ()
  "Toggle calendar popup.
When opening, display the 3-month calendar view."
  (interactive)
  (let ((calendar-window (calendar--window)))
    (if calendar-window
        (with-selected-window calendar-window
          (if (one-window-p t)
              (quit-window nil calendar-window)
            (delete-window calendar-window)))
      (setq denote-journal--origin-window (selected-window))
      ;; Opening via toggle should start from normal 3-month state.
      (setq calendar--window-configuration-before-12-month nil)
      (calendar--show-3-month))))
