;;; .emacs.d/init.el : Mark Tran <mark@nirv.net>

;; load paths
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((lisp-dir (expand-file-name "~/.emacs.d/"))
           (default-directory lisp-dir))
      (setq load-path (cons lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; load
(require 'cl)
(require 'eldoc)
(require 'thingatpt)
(require 'uniquify)

;; el-get
(require 'mqt-el-get)

;; init
(require 'mqt-functions)
(require 'mqt-keybindings)
(require 'mqt-lisp)
(require 'mqt-misc)
(require 'mqt-modes)
(require 'mqt-python)
(require 'mqt-ruby)
(require 'mqt-ui)

(when (eq window-system 'ns)
  (require 'mqt-mac))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
(load "~/.emacs.d/local.el" 'noerror)

;; start server
(server-start)
