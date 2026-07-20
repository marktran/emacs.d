(setq native-comp-enable-subprocess t)
(setq native-comp-deferred-compilation t)
(setq native-comp-async-report-warnings-errors nil)

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
                  mode-line-format-right-align
                  ;; Play icon while EMMS is actively playing (see
                  ;; settings/emms.el); nothing when paused/stopped.
                  ;; The gap is a fixed-width space: it measures and
                  ;; renders identically, so the icon's fallback-font
                  ;; glyph can't push the padding off the window edge,
                  ;; and its width mirrors the front-space padding.
                  (:eval (when (and (bound-and-true-p emms-player-playing-p)
                                    (not (bound-and-true-p emms-player-paused-p)))
                           (concat "\u25B6"
                                   (propertize " " 'display
                                               '(space :width 1.5)))))
                  mode-line-end-space)))

(add-hook 'after-init-hook #'restore-mode-line)

(load "~/.emacs.d/custom.el" 'noerror)

(load-file "~/.emacs.d/packages.el")
(mapc 'load (directory-files "~/.emacs.d/lisp" t "\\.el\\'"))
(load "~/.emacs.d/lisp/hacks/ignore-nil-mouse-events.el" 'noerror)
(load-file "~/.emacs.d/bindings.el")
(load-file "~/.emacs.d/settings.el")
(load-file "~/.emacs.d/interface.el")
(load-file "~/.emacs.d/platform.el")

(setq user-full-name "Mark Tran"
      user-mail-address "mark.tran@gmail.com")

(load "~/.emacs.d/local.el" 'noerror)
