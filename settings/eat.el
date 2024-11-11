(use-package eat
  :custom
  (eat-kill-buffer-on-exit t)
  (eat-query-before-killing-running-terminal nil)

  :general
  (:keymaps 'eat-semi-char-mode-map
   "C-d" 'popper-toggle
   "M-`" 'popper-cycle))
