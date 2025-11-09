(defun popper-close-window-hack (&rest _)
    "Close popper window via `C-g'."
    (when (and (called-interactively-p 'interactive)
               (not (region-active-p))
               popper-open-popup-alist)
      (let ((window (caar popper-open-popup-alist)))
        (when (window-live-p window)
          (delete-window window)))))

(use-package popper
  :ensure t

  :custom
  (popper-reference-buffers
   '("^\\*Backtrace\\*$" backtrace-mode
     "^\\*eat\\*$" eat-mode
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*Compile-Log\\*$"
     calendar-mode
     help-mode
     "^\\*Messages\\*$"
     "^\\*Warnings\\*$"))
  (popper-window-height 0.70)

  :hook
  (after-init . popper-mode)

  :general
  (:keymaps 'popper-mode-map
   "M-`" 'popper-cycle)

  (:prefix "SPC t"
   "" '(:ignore t :which-key "Toggles")
   "p" '(popper-toggle :which-key "Popper"))

  :config
  ;; Ensure `C-g` closes popper windows
  (advice-add #'keyboard-quit :before #'popper-close-window-hack))
