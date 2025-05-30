(use-package vertico
  :ensure t
  :demand t

  :custom
  (vertico-count 15)

  :hook
  (rfn-eshadow-update-overlay . vertico-directory-tidy)

  :general
  (:keymaps 'vertico-map
   "RET" 'vertico-directory-enter
   "DEL" 'vertico-directory-delete-char
   "M-DEL" 'vertico-directory-delete-word)

  :config
  (vertico-mode 1)
  (require 'vertico-directory))

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
  :demand t

  :custom
  (marginalia-align 'left)
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  (marginalia-max-relative-age 0)

  :general
  (:keymaps 'minibuffer-local-map
   "M-A" 'marginalia-cycle)

  :config
  (marginalia-mode 1)
  (advice-add #'marginalia-cycle :after
              (lambda ()
                (let ((inhibit-message t))
                  (customize-save-variable 'marginalia-annotator-registry
                                           marginalia-annotator-registry)))))

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
