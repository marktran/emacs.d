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
  ;; Prepended (not appended): jinx joins all exclusions into one
  ;; alternation where the first match wins, and jinx's stock patterns
  ;; (e.g. words-with-digits) would otherwise match a shorter prefix of
  ;; a compound like "rp1-pio" and strand its tail for solo checking.
  (setq jinx-exclude-regexps
        (append '((t "\\<\\w+\\(?:/[[:alnum:]._~-]+\\)+\\>")        ;; Ignore slash paths/slugs: "dir/file.ext", "owner/repo"
                  (t "\\<\\w+\\(?:\\.\\w+\\)+\\(?:/\\S-*\\)?\\>") ;; Ignore dotted names: domains, "file.el", "host.tld/path"
                  (t "\\<[[:alnum:]]+\\(?:-[[:alnum:]]+\\)+\\>")  ;; Ignore hyphenated compounds (tool/model names)
                  (t "\\<[[:alpha:]]+['\u2019]s\\>")                ;; Ignore possessives; aspell's list has holes (dog's yes, fault's no)
                  (t "\\b[A-Z][a-z]+\\b")                         ;; Ignore proper nouns (capitalized words)
                  (t "\\<[[:alpha:]]*[A-Z][[:alpha:]]*[A-Z][[:alpha:]]*\\>") ;; Ignore words with 2+ capitals
                  (t "\\<[a-z]+[A-Z][[:alpha:]]*\\>"))             ;; Ignore lower camelCase words
                jinx-exclude-regexps)))

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
