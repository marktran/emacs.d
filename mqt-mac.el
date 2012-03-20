;;; .emacs.d/mqt-mac.el : Mark Tran <mark@nirv.net>

;; settings
(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t
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

(defun copy-from-osx ()
   (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
   (let ((process-connection-type nil))
        (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
               (process-send-string proc text)
                     (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

(provide 'mqt-mac)
