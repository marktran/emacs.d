(use-package js-mode
  :ensure nil
  :config
  (setq-default js-indent-level 2))

(use-package js2-mode
  :mode ("\\.js\\'" . js2-mode)

  :init
  (rename-modeline "js2-mode" js2-mode "Javascript")

  :config
  (setq js2-basic-offset 2))
