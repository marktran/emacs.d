(require 'golden-ratio)

(dolist (command '(evil-window-left
                   evil-window-up
                   evil-window-right
                   evil-window-down
                   select-window-1
                   select-window-2
                   select-window-3
                   select-window-4))
  (add-to-list 'golden-ratio-extra-commands command))

(golden-ratio-mode)
