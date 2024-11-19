(use-package modus-themes
  :ensure t

  :custom
  (modus-themes-common-palette-overrides
      '(
        (border-mode-line-active bg-mode-line-active)
        (border-mode-line-inactive bg-mode-line-inactive)
        (fringe unspecified)))

  :config
  (load-theme 'modus-vivendi t))

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
