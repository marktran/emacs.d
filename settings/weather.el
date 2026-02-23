(use-package weather
  :ensure nil

  :custom
  (weather-location "Newport Beach, CA")

  :general
  ("SPC w" '(weather :which-key "Weather"))
  (:states 'normal :keymaps 'weather-mode-map
   "q" 'quit-window))
