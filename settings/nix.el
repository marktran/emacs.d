(defun m/maybe-nix-eglot ()
  "Start Eglot for Nix buffers when a Nix language server is available."
  (when (or (executable-find "nixd")
            (executable-find "nil"))
    (eglot-ensure)))

(use-package nix-ts-mode
  :ensure t
  :mode "\\.nix\\'"

  :hook (nix-ts-mode . m/maybe-nix-eglot)

  :config
  ;; nix-ts-mode doesn't register a grammar source, so do it here and
  ;; install on demand (matches treesit-auto-install preference).
  (add-to-list 'treesit-language-source-alist
               '(nix "https://github.com/nix-community/tree-sitter-nix"))
  (unless (treesit-language-available-p 'nix)
    (treesit-install-language-grammar 'nix))

  ;; Prefer nixd, fall back to nil; both speak the Nix LSP protocol.
  (with-eval-after-load 'eglot
    (setf (alist-get 'nix-ts-mode eglot-server-programs)
          (eglot-alternatives '("nixd" "nil"))))

  ;; apheleia already maps nix-ts-mode -> nixfmt, so format-on-save
  ;; works once nixfmt is on PATH; nothing extra needed here.
  )
