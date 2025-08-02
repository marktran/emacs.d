(use-package ef-themes
  :ensure t

  :config
  (load-theme 'ef-dark t))

(use-package modus-themes
  :ensure t

  :custom
  (modus-themes-common-palette-overrides
      '(
        (border-mode-line-active bg-mode-line-active)
        (border-mode-line-inactive bg-mode-line-inactive)
        (fringe unspecified))))

(use-package pulsar
  :ensure t

  :custom
  (pulsar-delay 0.055)
  (pulsar-face 'pulsar-yellow)
  (pulsar-iterations 10)
  (pulsar-pulse t)

  :hook
  ((next-error . (pulsar-pulse-line-red pulsar-recenter-top pulsar-reveal-entry)))

  :general
  ("SPC l" '(pulsar-pulse-line :which-key "Pulse Line"))

  :config
  (pulsar-global-mode 1))

(use-package spacious-padding
  :ensure t

  :custom
  spacious-padding-widths '(:internal-border-width 15
                            :header-line-width 4
                            :mode-line-width 2
                            :tab-width 4
                            :right-divider-width 30
                            :scroll-bar-width 8
                            :fringe-width 8)

  :config
  (spacious-padding-mode))
