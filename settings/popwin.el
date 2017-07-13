(use-package popwin
  :init
  (setq popwin:special-display-config nil)

  :config
  (add-to-list 'popwin:special-display-config
               '("^\*eshell .+\*$" :regexp t :height 0.5 :dedicated t :stick t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*Flycheck errors*" :height 0.4 :dedicated t :stick t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*Help*" :height 0.4 :dedicated t :stick t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("^\*Minitest.+\*$" :regexp t :height 0.4 :dedicated t :stick t :noselect t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*alchemist test report*" :height 0.4 :dedicated t :stick t :noselect t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*rspec-compilation*" :height 0.4 :dedicated t :stick t :noselect t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*swiper*" :height 0.4 :regexp t))

  (popwin-mode 1))
