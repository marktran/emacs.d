(use-package golden-ratio
  :ensure t
  :diminish golden-ratio-mode
  :commands (toggle-golden-ratio-mode)

  :config
  (setq golden-ratio-extra-commands
        (append golden-ratio-extra-commands
                '(evil-window-left
                  evil-window-right
                  evil-window-up
                  evil-window-down
                  buf-move-left
                  buf-move-right
                  buf-move-up
                  buf-move-down
                  winum-select-window-by-number
                  winum-select-window-0-or-10
                  winum-select-window-1
                  winum-select-window-2
                  winum-select-window-3
                  winum-select-window-4
                  winum-select-window-5
                  winum-select-window-6
                  winum-select-window-7
                  winum-select-window-8
                  winum-select-window-9)))

  :general
  (:prefix "SPC t"
   "" '(:ignore t :which-key "Toggle")
   "g" '(toggle-golden-ratio-mode :which-key "Golden ratio sizing")))
