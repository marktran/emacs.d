;;; .emacs.d/mqt-python.el : Mark Tran <mark@nirv.net>

(setq py-python-command-args '("-colors" "NoColor"))

(eval-after-load 'python-mode
  '(progn
     (require 'ipython)))

(add-hook 'python-mode-hook
          '(lambda () (whitespace-mode 1)) t)

(provide 'mqt-python)
