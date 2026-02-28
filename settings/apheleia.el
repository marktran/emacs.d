(use-package apheleia
  :ensure t
  :diminish apheleia-mode
  :commands (apheleia-mode apheleia-format-buffer)

  :config
  ;; Use oxfmt in JS/TS/JSON buffers.
  (dolist (mode '(javascript-ts-mode
                  typescript-ts-mode
                  json-ts-mode
                  json-mode
                  js-json-mode))
    (setf (alist-get mode apheleia-mode-alist) 'oxfmt)))
