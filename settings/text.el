(use-package flyspell
  :ensure nil
  :diminish flyspell-mode)

(use-package text-mode
  :ensure nil

  :hook
  ((text-mode . turn-on-auto-fill)
   (text-mode . flyspell-mode)))
