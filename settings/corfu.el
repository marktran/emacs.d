(use-package corfu
  :custom
  (corfu-auto t)          ;; Enable auto completion
  (corfu-auto-prefix 2)   ;; Complete after 2 characters
  (corfu-auto-delay 0.0)  ;; No delay for completions
  (corfu-preview-current nil)    ;; Disable preview
  (corfu-preselect 'first)       ;; Preselect first candidate
  (corfu-on-exact-match nil)     ;; Don't auto-confirm if exact match
  (corfu-quit-at-boundary t)     ;; Quit at completion boundary
  (corfu-quit-no-match t)        ;; Quit if there's no match
  (corfu-cycle t)                ;; Enable cycling through candidates

  :general
  (:keymaps 'corfu-map
   "TAB"     #'corfu-next
   [tab]     #'corfu-next
   "S-TAB"   #'corfu-previous
   [backtab] #'corfu-previous)

  :init
  (global-corfu-mode))

;; Optional but recommended: Enable icons in completions
(use-package kind-icon
  :after corfu
  :custom
  (kind-icon-default-face 'corfu-default)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

;; Enable indentation and completion using TAB
(use-package cape
  :after corfu
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))
