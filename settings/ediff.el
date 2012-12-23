(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))
