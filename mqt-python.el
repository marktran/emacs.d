;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-python.el : Mark Tran <mark@nirv.net>

(autoload 'python-mode "python-mode" "Python Mode" t)
(eval-after-load 'python-mode
  '(require 'ipython))

(setq ipython-command "/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/ipython"
      py-python-command-args '("-colors" "NoColor"))

;; syntax checking with flymakes and pyflakes
(when (load "flymake" t) 
  (defun flymake-pyflakes-init () 
    (let* ((temp-file (flymake-init-create-temp-buffer-copy 
                       'flymake-create-temp-inplace)) 
           (local-file (file-relative-name 
                        temp-file 
                        (file-name-directory buffer-file-name)))) 
      (list "pyflakes-2.6" (list local-file)))) 

  (add-to-list 'flymake-allowed-file-name-masks 
               '("\\.py\\'" flymake-pyflakes-init))) 

;; (add-hook 'find-file-hook 'flymake-find-file-hook)

(provide 'mqt-python)
