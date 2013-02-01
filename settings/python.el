(setq py-python-command-args '("-colors" "NoColor"))

(add-hook 'python-mode-hook
          '(lambda ()
             (setq evil-shift-width python-indent)))

(add-hook 'python-mode-hook 'run-coding-hook)
