(use-package popwin
  :ensure t

  :init
  (setq popwin:special-display-config nil)

  :config
  (add-to-list 'popwin:special-display-config '("*Help*" :width 80 :position right))
  (popwin-mode t))
