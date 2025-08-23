(cond
 ((eq system-type 'darwin)
  (load-file "~/.emacs.d/platform/darwin.el"))
 ((eq system-type 'gnu/linux)
  (load-file "~/.emacs.d/platform/linux.el")))
