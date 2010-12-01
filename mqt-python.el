;;; .emacs.d/mqt-python.el : Mark Tran <mark@nirv.net>

(autoload 'python-mode "python-mode" nil t)

(setq ipython-command "/usr/local/Cellar/python/2.7.1/bin/ipython"
      py-python-command-args '("-colors" "NoColor"))

(eval-after-load 'python-mode
  '(progn
     (require 'ipython)))

(add-hook 'python-mode-hook
          '(lambda () (whitespace-mode 1)) t)

(provide 'mqt-python)
