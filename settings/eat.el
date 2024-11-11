(use-package eat
  :custom
  (eat-query-before-killing-running-terminal nil)

  :general
  (:keymaps 'eat-semi-char-mode-map
   "C-d" 'popper-toggle))
