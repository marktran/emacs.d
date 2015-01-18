(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t
      dired-use-ls-dired t
      insert-directory-program "gls"
      mouse-wheel-scroll-amount '(0.01))

(defun browse-url-default-macosx-browser (url &optional new-window)
  (interactive (browse-url-interactive-arg "URL: "))
  (start-process (concat "open " url) nil "open" url))

(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))
