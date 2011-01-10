;;; .emacs.d/mqt-mac.el : Mark Tran <mark@nirv.net>

;; settings
(setenv "PATH"
        (concat "/usr/local/bin" ":"
                "/usr/bin" ":"
                "/bin"))
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t
      exec-path '("/usr/local/bin"
                  "/usr/bin"
                  "/bin")
      mouse-wheel-scroll-amount '(0.01))

(add-to-list 'ido-ignore-files "\\.DS_Store")

;; bindings
(setq mac-command-modifier 'control
      mac-option-modifier 'meta)

;; ui
(setq initial-frame-alist `((left . 46) (top . 49)
                            (width . 190) (height . 57)))

(set-default-font "Menlo-12")

;; functions
(defun browse-url-default-macosx-browser (url &optional new-window)
  (interactive (browse-url-interactive-arg "URL: "))
  (start-process (concat "open " url) nil "open" "-g" url))

(provide 'mqt-mac)
