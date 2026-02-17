(let ((user-bin (expand-file-name "~/bin")))
  (setenv "PATH" (concat user-bin ":" (getenv "PATH")))
  (add-to-list 'exec-path user-bin))

(setq shell-file-name (executable-find "fish"))
(setq explicit-shell-file-name shell-file-name)

(setq select-enable-clipboard t)
(setq select-enable-primary t)
