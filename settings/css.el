(setq css-indent-offset 2)

(dolist (mode '(("\\.css$" . css-mode)
                ("\\.less$" . css-mode)
                ("\\.scss$" . css-mode)))
  (add-to-list 'auto-mode-alist mode))

(add-hook 'css-mode-hook  'zencoding-mode)
