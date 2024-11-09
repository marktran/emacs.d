(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
(global-set-key [remap fill-paragraph] #'fill-or-unfill)

(use-package general
  :config
  (setq general-default-keymaps 'evil-normal-state-map))

(use-package hydra)

(use-package which-key
  :diminish which-key-mode

  :config
  (setq which-key-idle-delay 0.5
        which-key-show-prefix nil
        which-key-sort-order 'which-key-prefix-then-key-order)

  (which-key-mode 1))
