;;; .emacs.d/init.el : Mark Tran <mark@nirv.net>

;; load paths
(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")

;; require built-in packages
(require 'cl)
(require 'compile)
(require 'eldoc)
(require 'thingatpt)
(require 'uniquify)

;; this needs to happen before packages like rvm.el load, which prepends the PATH
(setenv "PATH"
        (concat "/usr/local/bin" ":"
                "/usr/local/share/python" ":"
                "/usr/bin" ":"
                "/bin" ":"
                "/usr/local/share/npm/bin" ":"
                "/Users/mark/.rbenv/shims"))

;; set ansi colors before ansi-color-map is built somewhere in an el-get package
(setq ansi-color-names-vector ["#000000" "#cf6a4c" "#7ca563" "#8a9a95"
                               "#8a9a95" "#a8799c" "#f1e694" "#c3be98"]
      exec-path '("/usr/local/bin"
                  "/usr/bin"
                  "/bin"
                  "/usr/local/share/npm/bin"
                  "/Users/mark/.rbenv/shims"))

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
