(defun restore-mode-line ()
  (setq-default mode-line-format
                '("%e"
                  mode-line-front-space
                  mode-line-mule-info
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-frame-identification
                  mode-line-buffer-identification
                  "  "
                  mode-line-position
                  (vc-mode vc-mode)
                  "  "
                  mode-line-modes
                  mode-line-misc-info
                  mode-line-end-space)))

(add-hook 'after-init-hook #'restore-mode-line)

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
