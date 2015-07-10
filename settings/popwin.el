(use-package popwin
  :ensure t

  :init
  (setq popwin:special-display-config nil)

  :config
  (add-to-list 'popwin:special-display-config
               '("*Help*" :height 0.4 :dedicated t :stick t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("^\*helm.+\*$" :height 0.4 :regexp t))
  (add-to-list 'popwin:special-display-config
               '("*rspec-compilation*" :height 0.2 :dedicated t :stick t :noselect t :position bottom))

  (popwin-mode t))
