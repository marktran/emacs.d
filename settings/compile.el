(use-package compile
  :ensure nil
  :defer t

  :custom
  (compilation-message-face nil)
  (compilation-scroll-output t)

  :general
  (:keymaps 'compilation-mode-map
   "h" nil
   "0" nil
   "SPC" nil))
