(use-package popwin
  :init
  (setq popwin:special-display-config nil)

  :config
  (add-to-list 'popwin:special-display-config
               '("*Help*" :height 0.4 :dedicated t :stick t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("^\*[hH]+elm.*?\*$" :height 0.4 :regexp t))
  (add-to-list 'popwin:special-display-config
               '("^\*Minitest.+\*$" :height 0.3 :regexp t))
  (add-to-list 'popwin:special-display-config
               '("*rspec-compilation*" :height 0.3 :dedicated t :stick t :noselect t :position bottom))
  (add-to-list 'popwin:special-display-config
               '("*swiper*" :height 0.4 :regexp t))

  (popwin-mode 1))
