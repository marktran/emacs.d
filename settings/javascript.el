(use-package js
  :ensure nil

  :custom
  (javascript-ts-mode-indent-offset 2)

  :hook
  ((javascript-ts-mode . add-node-modules-path)
   (javascript-ts-mode . oxfmt-on-save-mode)))

(use-package typescript-ts-mode
  :ensure nil

  :custom
  (typescript-ts-mode-indent-offset 2)

  :hook
  ((typescript-ts-mode . add-node-modules-path)
   (typescript-ts-mode . oxfmt-on-save-mode))

  :general
  (:keymaps 'typescript-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(oxfmt-buffer :which-key "Format")))

(use-package reformatter
  :ensure t)

(reformatter-define oxfmt
  :program "oxfmt"
  :args (list "--stdin-filepath" input-file)
  :input-file (reformatter-temp-file))

(use-package add-node-modules-path
  :ensure t)
