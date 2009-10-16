;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init.el : Mark Tran <mark@nirv.net>

;; load paths
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((lisp-dir (expand-file-name "~/.emacs.d/"))
           (default-directory lisp-dir))
      (setq load-path (cons lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

;; elpa
(require 'package)
(package-initialize)
(require 'mqt-elpa)

;; init
(require 'mqt-functions)
(require 'mqt-keybindings)
(require 'mqt-lisp)
(require 'mqt-misc)
(require 'mqt-modes)
(require 'mqt-python)
(require 'mqt-ruby)
(require 'mqt-ui)

(when (eq system-type 'darwin)
  (require 'mqt-mac))

(setq custom-file "~/.emacs.d/mqt-custom.el")
(load custom-file 'noerror)

;; start server
(server-start)
