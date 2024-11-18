(use-package jinx
  :ensure t

  :hook
  (text-mode . jinx-mode)

  :custom
  (jinx-ispell-program "aspell")
  (jinx-ispell-dictionary "en_US"))
