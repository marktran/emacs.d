(use-package popper
  :custom
  (popper-reference-buffers
   '("^\\*eat\\*$" eat-mode
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*Help\\*$"
     "\\*Messages\\*"
     "\\*Warning\\*"))
  (popper-window-height 0.40)

  :general
  ("M-`" 'popper-cycle)

  (:prefix "SPC t"
   "p c" 'popper-cycle
   "p t" 'popper-toggle)

  :init
  (popper-mode 1))
