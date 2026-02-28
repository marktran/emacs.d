(use-package apheleia
  :ensure t
  :diminish apheleia-mode
  :commands (apheleia-mode apheleia-format-buffer)

  :hook
  ((json-ts-mode . apheleia-mode)
   (json-mode . apheleia-mode))

  :config
  ;; Force 2-space JSON formatting regardless of mode-specific indent vars.
  (setf (alist-get 'jq-json apheleia-formatters)
        '("jq" "-M" "--indent" "2" "."))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) 'jq-json
        (alist-get 'json-mode apheleia-mode-alist) 'jq-json))

(use-package json-ts-mode
  :ensure nil

  :custom
  (json-ts-mode-indent-offset 2)

  :hook
  (json-ts-mode . flymake-mode)

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
  ((json-mode . flymake-mode)
   (json-mode . (lambda () (setq-local js-indent-level 2))))

  :general
  (:keymaps 'json-mode-map
   :states 'normal
   :prefix "SPC"
   "b f" '(apheleia-format-buffer :which-key "Format")))
