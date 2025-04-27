(use-package exec-path-from-shell
  :ensure t

  :custom
  (exec-path-from-shell-variables '("PATH" "LIBRARY_PATH" "CPATH"))

  :config
  (exec-path-from-shell-initialize))
