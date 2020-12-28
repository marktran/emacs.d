(package-initialize)

(add-to-list 'load-path "~/.emacs.d/vendor")

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
