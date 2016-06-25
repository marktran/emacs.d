(use-package compile
  :ensure nil
  :defer t

  :general
  (:keymaps 'compilation-mode-map
   "h" nil
   "0" nil
   "SPC" nil)

  :config
  (setq compilation-message-face nil
        compilation-scroll-output t))


