(cond
 ((eq system-type 'darwin)
  (load-file "~/.emacs.d/os/darwin.el"))
 ((eq system-type 'gnu/linux)
  (load-file "~/.emacs.d/os/linux.el")))
