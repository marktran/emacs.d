(setq-default js-indent-level 2)

(use-package js
  :mode "\\.js\\'"
  :custom
  (js-indent-level 2))

(use-package typescript-ts-mode
  :custom
  (typescript-ts-mode-indent-offset 2)

  :general
  (:keymaps 'typescript-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(prettier-js :which-key "Format")))

(use-package treesit-auto
  :custom
  (treesit-auto-install t)
  (treesit-auto-langs '(html javascript json tsx typescript yaml))

  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package add-node-modules-path
  :hook
  (typescript-ts-mode . add-node-modules-path))

(use-package prettier-js
  :diminish ""

  :config
  (setq prettier-args '("--no-semi" "all"))

  :hook
  (typescript-ts-mode . prettier-js-mode))
