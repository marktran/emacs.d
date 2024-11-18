(use-package keycast
  :ensure t
  :commands (keycast-mode-line-mode keycast-header-line-mode keycast-tab-bar-mode keycast-log-mode)

  :custom
  (keycast-mode-line-format "%2s%k%c%R")
  (keycast-mode-line-remove-tail-elements nil)
  (keycast-mode-line-window-predicate 'mode-line-window-selected-p)

  :config
  (dolist (input '(self-insert-command org-self-insert-command))
    (add-to-list 'keycast-substitute-alist `(,input "." "Typing…")))

  (dolist (event '( mouse-event-p mouse-movement-p mwheel-scroll handle-select-window
                    mouse-set-point mouse-drag-region))
    (add-to-list 'keycast-substitute-alist `(,event nil))))
