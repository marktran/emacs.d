(setq py-python-command-args '("-colors" "NoColor"))

(add-hook 'python-mode-hook
          '(lambda () (whitespace-mode t)) t)

(add-hook 'python-mode-hook
  (function (lambda ()
          (setq evil-shift-width python-indent))))

(add-hook 'python-mode-hook 'run-coding-hook)
