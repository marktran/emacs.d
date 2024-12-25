(use-package flyspell
  :ensure nil
  :diminish)

(use-package ispell
  :ensure nil

  :custom
  (ispell-personal-dictionary "~/.emacs.d/.aspell.en.pws"))

(use-package jinx
  :ensure t
  :diminish

  :custom
  (jinx-ispell-program "aspell")
  (jinx-ispell-dictionary "en_US")

  :hook
  (text-mode . jinx-mode)

  :config
  (add-to-list 'jinx-exclude-regexps '(t "\\(?:\\(?:\\w+/\\)+\\w+\\.[[:alpha:]]+\\)")))

(use-package text-mode
  :ensure nil

  :hook
  ((text-mode . turn-on-auto-fill)))
