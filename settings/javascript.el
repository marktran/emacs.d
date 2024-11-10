(setq-default js-indent-level 2)

(use-package js2-mode
  :mode ("\\.js\\'" . js2-mode)

  :init
  (rename-modeline "js2-mode" js2-mode "Javascript")

  :config
  (setq js2-basic-offset 2))

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
  (treesit-auto-install 'prompt)

  :config
  (treesit-auto-add-to-auto-mode-alist 'all))

(use-package add-node-modules-path
  :hook
  (typescript-ts-mode . add-node-modules-path))

(use-package prettier-js
  :after js2-mode
  :diminish ""

  :config
  (setq prettier-args '("--no-semi" "all"))

  :hook
  (typescript-ts-mode . prettier-js-mode))
