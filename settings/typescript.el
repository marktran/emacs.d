(use-package typescript-mode
  :init
  (setq typescript-indent-level 2)

  :config
  (general-define-key :prefix "SPC"
    "b f" '(prettier-js :which-key "Format"))

  (add-hook 'typescript-mode-hook #'add-node-modules-path)
  (add-hook 'typescript-mode-hook #'prettier-js-mode)
  (add-hook 'typescript-mode-hook #'lsp))

(use-package eglot
  :config
  (add-hook 'eglot--managed-mode-hook #'eldoc-box-hover-mode t))

(use-package lsp-mode)

(use-package lsp-ui
  :init
  (setq lsp-ui-doc-use-webkit t)

  :config
  (setq lsp-ui-doc-use-webkit t))

(use-package company-lsp :commands company-lsp)
