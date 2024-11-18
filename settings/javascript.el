(use-package javascript-ts-mode
  :ensure nil

  :custom
  (javascript-ts-mode-indent-offset 2)

  :hook
  (javascript-ts-mode . add-node-modules-path))

(use-package typescript-ts-mode
  :ensure nil

  :custom
  (typescript-ts-mode-indent-offset 2)

  :hook
  (typescript-ts-mode . add-node-modules-path)

  :general
  (:keymaps 'typescript-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(prettier-js :which-key "Format")))

(use-package prettier
  :ensure t

  :hook
  ((javascript-ts-mode . prettier-mode)
   (typescript-ts-mode . prettier-mode)))

(use-package treesit-auto
  :ensure t

  :custom
  (treesit-auto-install t)
  (treesit-auto-langs '(html javascript json tsx typescript yaml))

  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package add-node-modules-path
  :ensure t)
