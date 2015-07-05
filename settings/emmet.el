(use-package emmet-mode
  :defer t

  :bind ("<backtab>" . emmet-expand-line)

  :config
  (setq emmet-indentation 2
        emmet-preview-default nil))
