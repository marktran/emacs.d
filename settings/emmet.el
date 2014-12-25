(use-package emmet-mode
  :ensure emmet-mode
  :bind (("<backtab>" . emmet-expand-line))
  :config
  (setq emmet-indentation 2
        emmet-preview-default nil))
