(use-package calendar
  :ensure nil

  :general
  (:keymaps 'calendar-mode-map
   :states '(emacs normal)
   "<tab>" 'toggle-calendar-view))
