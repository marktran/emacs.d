(require 'golden-ratio)

(dolist (command '(evil-window-left
                   evil-window-up
                   evil-window-right
                   evil-window-down))
  (add-to-list 'golden-ratio-extra-commands command))


