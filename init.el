;;; .emacs.d/init.el : Mark Tran <mark@nirv.net>

;; load paths
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")

;; require built-in packages
(require 'cl)
(require 'eldoc)
(require 'thingatpt)
(require 'uniquify)

;; this needs to happen before packages like rvm.el, which prepends the PATH
(setenv "PATH"
        (concat "/usr/local/bin" ":"
                "/usr/bin" ":"
                "/bin"))
(setq exec-path '("/usr/local/bin"
                  "/usr/bin"
                  "/bin"))

;; el-get
(load "~/.emacs.d/el-get/el-get/el-get.elc")
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
