(defun eat-send-backspace ()
  "Send backspace character to eat terminal."
  (interactive)
  (when (bound-and-true-p eat-terminal)
    (eat-term-send-string eat-terminal "\C-h")))

(use-package eat
  :ensure t

  :custom
  (eat-kill-buffer-on-exit t)
  (eat-query-before-killing-running-terminal nil)
  (eat-term-name "xterm-256color")

  :general
  (:keymaps 'eat-semi-char-mode-map
   "<backspace>" 'eat-send-backspace
   "<home>" 'beginning-of-buffer
   "<end>" 'end-of-buffer
   "<prior>" 'evil-scroll-up
   "<next>" 'evil-scroll-down
   "M-`" 'popper-cycle))
