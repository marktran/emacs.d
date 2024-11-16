(defun find-project-tsserver ()
  "Find the tsserver.js in the Rush monorepo PNPM structure."
  (let* ((project-root (or (project-root (project-current))
                          default-directory))
         (pnpm-dir (expand-file-name "node_modules/.pnpm/" project-root))
         (found-paths (directory-files-recursively pnpm-dir "tsserver\\.js$" nil))
         (typescript-paths (seq-filter 
                          (lambda (path) 
                            (string-match-p "typescript[@/].*tsserver\\.js$" path))
                          found-paths)))
    (car typescript-paths)))

(use-package eglot
  :hook (typescript-ts-mode . eglot-ensure)

  :custom
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)
  (eglot-autoshutdown t)
  (eglot-send-changes-idle-time 0.5)

  :config
  (when (executable-find "emacs-lsp-booster")
    (setq eglot-server-programs
          (mapcar (lambda (row)
                    (if (and (listp row)
                            (listp (cdr row)))
                        (cons (car row)
                              (append '("emacs-lsp-booster" "--verbose") (cdr row)))
                      row))
                  eglot-server-programs))
    
    (add-to-list 'eglot-server-programs
                 `(typescript-ts-mode
                   . ("typescript-language-server" "--stdio"
                      :initializationOptions
                      (:tsserver
                       (:path ,(or (find-project-tsserver)
                                 (error "Could not find tsserver.js")))))))))
