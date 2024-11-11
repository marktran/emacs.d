(use-package eat
  :custom
  (eat-kill-buffer-on-exit t)
  (eat-query-before-killing-running-terminal nil)

  :general
  (:keymaps 'eat-semi-char-mode-map
   "<home>" 'beginning-of-buffer
   "<end>" 'end-of-buffer
   "<prior>" 'evil-scroll-up
   "<next>" 'evil-scroll-down
   "M-`" 'popper-cycle))
