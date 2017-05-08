
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/vendor")

(require 'cl)
(require 'use-package)

(load "~/.emacs.d/local.el" 'noerror)
(load "~/.emacs.d/custom.el" 'noerror)

(load-file "~/.emacs.d/packages.el")
(mapc 'load (directory-files "~/.emacs.d/definitions" t "^[A-Za-z-]*\\.el"))
(load-file "~/.emacs.d/bindings.el")
(load-file "~/.emacs.d/settings.el")
(load-file "~/.emacs.d/interface.el")
(load-file "~/.emacs.d/platform.el")

(setq user-full-name "Mark Tran"
      user-mail-address "mark.tran@gmail.com")
