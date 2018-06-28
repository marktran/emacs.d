(setq browse-url-browser-function 'browse-url-default-macosx-browser
      delete-by-moving-to-trash t
      dired-use-ls-dired t
      insert-directory-program "gls"
      mouse-wheel-scroll-amount '(0.01)
      save-interprogram-paste-before-kill t)

(if (eq window-system 'mac)
    (set-face-attribute 'default nil :family "Operator Mono Medium" :height 130)
  (set-frame-font "Operator Mono Medium 13"))

(when (eq window-system 'mac)
  (toggle-frame-fullscreen))

(xterm-mouse-mode -1)

(defun browse-url-default-macosx-browser (url &optional new-window)
  (interactive (browse-url-interactive-arg "URL: "))
  (start-process (concat "open " url) nil "open" url))
