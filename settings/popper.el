(use-package popper
  :custom
  (popper-reference-buffers
   '("^\\*eat\\*$" eat-mode
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*Help\\*$"
     "\\*Messages\\*"
     "\\*Warning\\*"))

  :general
  ("M-`" 'popper-toggle)

  (:prefix "SPC t"
   "p c" 'popper-cycle
   "p t" 'popper-toggle)

  :init
  (popper-mode 1)
  (popper-echo-mode 1))
