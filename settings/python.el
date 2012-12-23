(setq py-python-command-args '("-colors" "NoColor"))

(add-hook 'python-mode-hook
          '(lambda () (whitespace-mode 1)) t)
