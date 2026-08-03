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
  ;; Enchant language; the personal wordlist lives at
  ;; ~/.config/enchant/en_US.dic (repo-managed, seeded with cspell's
  ;; software/devops dictionaries).
  (jinx-languages "en_US")

  :hook
  (text-mode . jinx-mode)

  :config
  (setq jinx-exclude-regexps
        (append jinx-exclude-regexps
                '((t "\\(?:\\(?:\\w+/\\)+\\w+\\.[[:alpha:]]+\\)") ;; Ignore file paths like "dir/file.ext"
                  (t "\\<\\w+\\(?:\\.\\w+\\)+\\>")               ;; Ignore dotted names: domains, "file.el"
                  (t "\\<[[:alnum:]]+\\(?:-[[:alnum:]]+\\)+\\>")  ;; Ignore hyphenated compounds (tool/model names)
                  (t "\\b[A-Z][a-z]+\\(?:['\u2019]s\\)?\\b")           ;; Ignore proper nouns, incl. possessive
                  (t "\\<[[:alpha:]]*[A-Z][[:alpha:]]*[A-Z][[:alpha:]]*\\(?:['\u2019]s\\)?\\>") ;; Ignore words with 2+ capitals
                  (t "\\<[a-z]+[A-Z][[:alpha:]]*\\(?:['\u2019]s\\)?\\>")))))  ;; Ignore lower camelCase words

(use-package text-mode
  :ensure nil

  :custom
  (text-mode-ispell-word-completion nil)

  :hook
  ((text-mode . turn-on-auto-fill)))

(use-package typo
  :ensure t
  :diminish

  :hook
  (text-mode . typo-mode))
