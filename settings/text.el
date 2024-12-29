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
  (setq jinx-exclude-regexps
        (append jinx-exclude-regexps
                '((t "\\(?:\\(?:\\w+/\\)+\\w+\\.[[:alpha:]]+\\)") ;; Match file paths like "dir/file.ext"
                  (t "\\<\\w+\\.el\\>")))))                       ;; Match Emacs Lisp files like "beframe.el"

(use-package text-mode
  :ensure nil

  :hook
  ((text-mode . turn-on-auto-fill)))

(use-package typo
  :ensure t
  :diminish

  :hook
  (text-mode . typo-mode))
