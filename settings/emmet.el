(use-package emmet-mode
  :diminish emmet-mode
  :bind ("<backtab>" . emmet-expand-line)

  :config
  (setq emmet-indentation 2
        emmet-preview-default nil)

  (defadvice emmet-expand-line (after evil-normal-state activate)
    "Enable Normal state after expansion"
    (evil-normal-state)))
