(defun find-project-tsserver ()
  "Find the tsserver.js in the Rush monorepo PNPM structure."
  (let* ((project-root (or (project-root (project-current))
                           default-directory))
         (pnpm-dir (expand-file-name "node_modules/.pnpm/" project-root)))
    (when (file-directory-p pnpm-dir)
      (let* ((found-paths (directory-files-recursively pnpm-dir "tsserver\\.js$" nil))
             (typescript-paths (seq-filter
                                (lambda (path)
                                  (string-match-p "typescript[@/].*tsserver\\.js$" path))
                                found-paths)))
        (car typescript-paths)))))

(use-package eglot
  :ensure nil

  :custom
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)
  (eglot-autoshutdown t)
  (eglot-send-changes-idle-time 0.5)

  :hook (typescript-ts-mode . eglot-ensure)

  :config
  (when (executable-find "emacs-lsp-booster")
    (setq eglot-server-programs
          (mapcar (lambda (row)
                    (if (and (listp row)
                             (listp (cdr row)))
                        (cons (car row)
                              (append '("emacs-lsp-booster" "--verbose") (cdr row)))
                      row))
                  eglot-server-programs)))

  (let ((tsserver-path (find-project-tsserver)))
    (if tsserver-path
        (add-to-list 'eglot-server-programs
                     `(typescript-ts-mode
                       . ("typescript-language-server" "--stdio"
                          :initializationOptions
                          (:tsserver (:path ,tsserver-path)))))
      (message "Warning: Could not find tsserver.js"))))
