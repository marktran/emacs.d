;;; .emacs.d/mqt-mac.el : Mark Tran <mark@nirv.net>

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t)

(add-to-list 'ido-ignore-files "\\.DS_Store")

;; bindings
(setq mac-command-modifier 'control
      mac-option-modifier 'meta)

;; ui
(setq initial-frame-alist `((left . 64) (top . 63)
                            (width . 185) (height . 55)))

(set-default-font "Menlo-12")

;; functions
(defun browse-url-default-macosx-browser (url &optional new-window)
  (interactive (browse-url-interactive-arg "URL: "))
  (start-process (concat "open " url) nil "open" "-g" url))

(provide 'mqt-mac)
