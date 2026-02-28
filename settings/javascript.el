(use-package js
  :ensure nil

  :custom
  (javascript-ts-mode-indent-offset 2)

  :hook
  (((javascript-ts-mode typescript-ts-mode js-json-mode) . add-node-modules-path)
   ((javascript-ts-mode typescript-ts-mode js-json-mode) . apheleia-mode)
   (js-json-mode . (lambda () (setq-local js-indent-level 2))))

  :general
  (:keymaps 'javascript-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format"))

  :general
  (:keymaps 'js-json-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format")))

(use-package typescript-ts-mode
  :ensure nil

  :custom
  (typescript-ts-mode-indent-offset 2)

  :general
  (:keymaps 'typescript-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format")))

(use-package add-node-modules-path
  :ensure t)
