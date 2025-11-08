(use-package calendar
  :ensure nil

  :custom
  (calendar-holidays
   '((holiday-fixed 1 1 "New Year's Day")
     (holiday-float 1 1 3 "Martin Luther King Jr. Day")
     (holiday-float 2 1 3 "Presidents' Day")
     (holiday-float 5 1 -1 "Memorial Day")
     (holiday-fixed 6 19 "Juneteenth")
     (holiday-fixed 7 4 "Independence Day")
     (holiday-float 9 1 1 "Labor Day")
     (holiday-float 10 1 2 "Columbus Day")
     (holiday-fixed 11 11 "Veterans Day")
     (holiday-float 11 4 4 "Thanksgiving Day")
     (holiday-fixed 12 25 "Christmas Day")))

  (calendar-mark-holidays-flag t)
  (calendar-mode-line-format nil)

  :general
  (:keymaps 'calendar-mode-map
   :states '(emacs normal)
   "<tab>" 'toggle-calendar-view))
