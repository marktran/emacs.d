;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-python.el : Mark Tran <mark@nirv.net>

(autoload 'python-mode "python-mode" nil t)

(setq ipython-command
      "/opt/local/Library/Frameworks/Python.framework/Versions/2.6/bin/ipython"
      py-python-command-args '("-colors" "NoColor"))

;; (eval-after-load 'python-mode
;;   '(progn
;;      (require 'ipython)
;;      (require 'pymacs)
;;      (pymacs-load "ropemacs" "rope-")))

(eval-after-load 'python-mode
  '(progn
     (require 'ipython)))

;; flymake
(defvar flymake-python-allowed-file-name-masks
  '(("\\.py\\'" flymake-python-init)))
(defvar flymake-python-pyflakes-executable
  "pyflakes-2.6")

(defun flymake-python-init ()
  (list flymake-python-pyflakes-executable
        (list (file-relative-name
               (flymake-init-create-temp-buffer-copy
                'flymake-create-temp-inplace)
               (file-name-directory buffer-file-name)))))

(defun flymake-python-load ()
  (interactive)
  (set (make-local-variable 'flymake-allowed-file-name-masks)
       flymake-python-allowed-file-name-masks)
  (flymake-mode t))

;; (add-hook 'python-mode-hook
;;           (lambda ()
;;             (if (and (not (null buffer-file-name))
;;                      (file-writable-p buffer-file-name))
;;                 (flymake-python-load))))

(provide 'mqt-python)
