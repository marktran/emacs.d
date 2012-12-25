(add-to-list 'load-path "~/.emacs.d/vendor")

(load-file "~/.emacs.d/packages.el")
(load-file "~/.emacs.d/functions.el")
(load-file "~/.emacs.d/settings.el")
(load-file "~/.emacs.d/bindings.el")
(load-file "~/.emacs.d/interface.el")
(load-file "~/.emacs.d/platform.el")

(load "~/.emacs.d/custom.el" 'noerror)
(load "~/.emacs.d/local.el" 'noerror)
