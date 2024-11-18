(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
(global-set-key [remap fill-paragraph] #'fill-or-unfill)

(use-package general
  :ensure t
  :custom
  (general-default-keymaps 'evil-normal-state-map))

(use-package hydra
  :ensure t)

(use-package which-key
  :ensure t
  :diminish which-key-mode

  :custom
  (which-key-idle-delay 0.5)
  (which-key-show-prefix nil)
  (which-key-sort-order 'which-key-prefix-then-key-order)

  :config
  (which-key-mode 1))
