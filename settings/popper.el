(defun popper-close-window-hack (&rest _)
    "Close popper window via `C-g'."
    (when (and (called-interactively-p 'interactive)
               (not (region-active-p))
               popper-open-popup-alist)
      (let ((window (caar popper-open-popup-alist)))
        (when (window-live-p window)
          (delete-window window)))))

(use-package popper
  :custom
  (popper-reference-buffers
   '("^\\*eat\\*$" eat-mode
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*Help\\*$"
     "\\*Messages\\*"
     "\\*Warnings\\*"))
  (popper-window-height 0.40)

  :general
  (:keymaps 'popper-mode-map
   "M-`" 'popper-cycle)

  (:prefix "SPC t"
   "" '(:ignore t :which-key "Toggle")
   "p" '(popper-toggle :which-key "Popper"))

  :init
  (popper-mode 1)

  ;; `C-g' can deactivate region
  (advice-add #'keyboard-quit :before #'popper-close-window-hack))

