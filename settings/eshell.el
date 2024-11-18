(use-package eshell
  :ensure nil

  :custom
  (eshell-aliases-file "~/.emacs.d/eshell/alias")
  (eshell-banner-message "")
  (eshell-cmpl-cycle-completions nil)
  (eshell-cmpl-dir-ignore "\\`\$begin:math:text$\\\\.\\\\.?\\\\|CVS\\\\|\\\\.svn\\\\|\\\\.git\\$end:math:text$/\\'")
  (eshell-highlight-prompt nil)
  (eshell-history-size 4096)
  (eshell-last-dir-ring-size 10)
  (eshell-list-files-after-cd t)
  (eshell-prompt-function
   (lambda ()
     (concat
      (propertize (fish-path (eshell/pwd) 20) 'face '(:foreground "#cd00cd"))
      " ")))
  (eshell-prompt-regexp "^[^ ]* ")
  (eshell-review-quick-commands t)
  (eshell-smart-space-goes-to-end t)
  (eshell-where-to-jump 'begin)

  :general
  (:keymaps 'eshell-mode-map
   "TAB" 'completion-at-point
   "DEL" 'eshell-delete-backward-char
   "C-d" 'bury-buffer
   "C-n" 'eshell-next-input
   "C-p" 'eshell-previous-input)

  (:keymaps 'eshell-mode-map :prefix "C-w"
   "=" 'balance-windows
   "h" 'windmove-left
   "C-h" 'windmove-left
   "l" 'windmove-right
   "C-l" 'windmove-right
   "j" 'windmove-down
   "C-j" 'windmove-down
   "k" 'windmove-up
   "C-k" 'windmove-up
   "C-o" 'delete-other-windows
   "c" 'delete-window
   "u" 'winner-undo)

  :config
  (require 'em-rebind))
