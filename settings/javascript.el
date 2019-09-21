(setq-default js-indent-level 2)

(use-package js2-mode
  :mode ("\\.js\\'" . js2-mode)

  :init
  (rename-modeline "js2-mode" js2-mode "Javascript")

  :config
  (setq js2-basic-offset 2))

(use-package add-node-modules-path)

(use-package prettier-js
  :after js2-mode
  :config
  (setq prettier-args '("--no-semi" "all")))
