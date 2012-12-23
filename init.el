(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/.emacs.d/vendor")

(load-file "~/.emacs.d/platform/mac.el")
(load-file "~/.emacs.d/packages.el")
(load-file "~/.emacs.d/functions.el")
(load-file "~/.emacs.d/settings.el")
(load-file "~/.emacs.d/keybindings.el")
(load-file "~/.emacs.d/ui.el")

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)
(load "~/.emacs.d/local.el" 'noerror)
