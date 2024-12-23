(use-package flyspell
  :ensure nil
  :diminish flyspell-mode)

(use-package ispell
  :ensure nil

  :custom
  (ispell-personal-dictionary "~/.emacs.d/.aspell.en.pws"))

(use-package jinx
  :ensure t
  :diminish jinx-mode

  :hook
  (text-mode . jinx-mode)

  :custom
  (jinx-ispell-program "aspell")
  (jinx-ispell-dictionary "en_US"))

(use-package text-mode
  :ensure nil

  :hook
  ((text-mode . turn-on-auto-fill)
   (text-mode . flyspell-mode)))
