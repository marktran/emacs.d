(use-package flymake-collection
  :ensure t
  :commands flymake-collection-jq)

(defun m/json-enable-flymake-jq ()
  "Enable Flymake diagnostics for JSON using jq backend."
  (add-hook 'flymake-diagnostic-functions #'flymake-collection-jq nil t)
  (flymake-mode 1))

(use-package json-ts-mode
  :ensure nil

  :custom
  (json-ts-mode-indent-offset 2)

  :hook
  (((json-ts-mode json-mode) . add-node-modules-path)
   ((json-ts-mode json-mode) . m/json-enable-flymake-jq)
   ((json-ts-mode json-mode) . apheleia-mode))

  :general
  (:keymaps 'json-ts-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format")))

(use-package json-mode
  :ensure t

  :custom
  (json-reformat:indent-width 2)

  :hook
  (json-mode . (lambda () (setq-local js-indent-level 2)))

  :general
  (:keymaps 'json-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format")))
