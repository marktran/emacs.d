(use-package text-mode
  :ensure nil
  :diminish flyspell-mode

  :hook
  ((text-mode . turn-on-auto-fill)
   (text-mode . flyspell-mode)))
