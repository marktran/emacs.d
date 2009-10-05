;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-python.el : Mark Tran <mark@nirv.net>

;; python-mode
(setq auto-mode-alist (cons '("\\.py$" . python-mode) auto-mode-alist))
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(require 'python-mode)

(add-hook 'python-mode-hook 'turn-on-eldoc-mode)

;; ipython
(setq ipython-command "/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/ipython"
      py-python-command-args '("-colors" "NoColor"))
(require 'ipython)

(provide 'mqt-python)
