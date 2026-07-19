(defun toggle-golden-ratio-mode ()
  (interactive)
  (if golden-ratio-mode
      (progn
        (golden-ratio-mode -1)
        (balance-windows))
    (golden-ratio-mode 1)
    (golden-ratio)))
