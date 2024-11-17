(setq completion-ignored-extensions
      (nconc completion-ignored-extensions '(".DS_Store")))

(use-package vertico
  :custom
  (vertico-count 15)

  :init
  (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil

  :bind
  (:map vertico-map
         ("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word))

  ;; Tidy shadowed file names
  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package vertico-posframe
  :after vertico
  :init
  (vertico-posframe-mode 1))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package marginalia
  :after vertico

  :custom
  (marginalia-align 'right)
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  (marginalia-max-relative-age 0)

  :config
  (add-to-list 'marginalia-annotator-registry '(file none marginalia-annotate-file))
  (add-to-list 'marginalia-annotator-registry '(multi-category none marginalia-annotate-multi-category))

  :bind
  (("M-A" . marginalia-cycle))

  :init
  (marginalia-mode))

(use-package orderless
  :after vertico
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless partial-completion))
  (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion orderless)))))
