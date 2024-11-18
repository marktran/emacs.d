(use-package vertico
  :ensure t

  :custom
  (vertico-count 15)

  :hook
  ((after-init . vertico-mode)
   (rfn-eshadow-update-overlay . vertico-directory-tidy))

  :general
  (:keymaps 'vertico-map
   "RET" 'vertico-directory-enter
   "DEL" 'vertico-directory-delete-char
   "M-DEL" 'vertico-directory-delete-word)

  :config
  (require 'vertico-directory))

(use-package vertico-posframe
  :ensure t
  :after vertico

  :config
  (vertico-posframe-mode))

(use-package completion
  :ensure nil
  :custom
  (completion-ignored-extensions
   (nconc completion-ignored-extensions '(".DS_Store"))))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure nil
  :config
  (savehist-mode 1))

(use-package marginalia
  :ensure t
  :after vertico

  :custom
  (marginalia-align 'right)
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  (marginalia-max-relative-age 0)

  :general
  (:keymaps 'minibuffer-local-map
   "M-A" 'marginalia-cycle)

  :config
  (marginalia-mode 1)
  (add-to-list 'marginalia-annotator-registry
               '(file none marginalia-annotate-file))
  (add-to-list 'marginalia-annotator-registry '(multi-category none marginalia-annotate-multi-category)))

(use-package orderless
  :ensure t
  :after vertico

  :custom
  (completion-styles '(orderless partial-completion))
  (orderless-matching-styles
   '(orderless-initialism orderless-literal orderless-regexp))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion orderless)))))
