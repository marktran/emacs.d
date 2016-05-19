(use-package python
  :mode "\\.py\\'"

  :config
  (add-hook 'python-mode-hook 'run-coding-hook))
