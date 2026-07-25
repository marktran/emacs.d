(use-package scratch
  :ensure t
  :commands (scratch))

;; Startup puts *scratch* in `initial-major-mode' (the default
;; `lisp-interaction-mode') on its own; just add paredit and keep the
;; buffer from being killed.
(add-hook 'emacs-startup-hook
          (lambda ()
            (with-current-buffer "*scratch*"
              (paredit-mode)
              (emacs-lock-mode 'kill))))
