(use-package popper
  :ensure t

  :preface
  (defun popper-close-window-hack (&rest _)
    "Close popper window via `C-g'."
    (when (and (called-interactively-p 'interactive)
               (not (region-active-p))
               popper-open-popup-alist)
      (let ((window (caar popper-open-popup-alist)))
        (when (window-live-p window)
          (delete-window window)))))

  :custom
  (popper-reference-buffers
   '("^\\*Backtrace\\*$" backtrace-mode
     "^\\*eat\\*$" eat-mode
     "^\\*eshell.*\\*$" eshell-mode
     "^\\*Compile-Log\\*$"
     calendar-mode
     weather-mode
     help-mode
     "^\\*Messages\\*$"
     "^\\*Warnings\\*$"))
  (popper-window-height
   (lambda (win)
     (with-current-buffer (window-buffer win)
       (pcase major-mode
         ('calendar-mode
          (if (eq calendar-view-mode '12-month)
              (let ((height (floor (* (frame-height) 0.95))))
                (fit-window-to-buffer win height height))
            (fit-window-to-buffer
             win
             (if (boundp 'calendar-row-height) (+ calendar-row-height 2) 12)
             8)))
         ('weather-mode
          (fit-window-to-buffer win 12 8))
         (_
          (let ((height (floor (* (frame-height) 0.40))))
            (fit-window-to-buffer win height height)))))))

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
