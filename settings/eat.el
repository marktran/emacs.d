(use-package eat
  :ensure t

  :custom
  (eat-kill-buffer-on-exit t)
  (eat-query-before-killing-running-terminal nil)
  (eat-term-name "xterm-256color")

  :config
  (when (eq system-type 'gnu/linux)
    (setq explicit-shell-file-name "/usr/bin/fish"))

  :general
  (:keymaps 'eat-semi-char-mode-map
   "<home>" 'beginning-of-buffer
   "<end>" 'end-of-buffer
   "<prior>" 'evil-scroll-up
   "<next>" 'evil-scroll-down
   "M-`" 'popper-cycle))
