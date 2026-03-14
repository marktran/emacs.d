(defun m/project-root (&optional project)
  "Return root directory for PROJECT or current project."
  (when-let* ((proj (or project (project-current))))
    (project-root proj)))

(defun m/find-project-bin (name &optional project)
  "Find executable NAME in project-local node_modules/.bin, if present."
  (when-let* ((root (m/project-root project))
              (bin (expand-file-name (concat "node_modules/.bin/" name) root))
              ((file-executable-p bin)))
    bin))

(defun m/typescript-project-p (&optional project)
  "Return non-nil when PROJECT or current project looks like a TS/JS project."
  (when-let* ((root (m/project-root project)))
    (catch 'found
      (dolist (name '("tsconfig.json" "jsconfig.json" "package.json"
                      "deno.json" "deno.jsonc"))
        (when (file-exists-p (expand-file-name name root))
          (throw 'found t)))
      nil)))

(defun m/find-project-tsserver (&optional project)
  "Find a project-local tsserver.js path for PROJECT."
  (when-let* ((root (m/project-root project)))
    (or
     ;; npm/yarn layout
     (let ((npm-tsserver (expand-file-name "node_modules/typescript/lib/tsserver.js" root)))
       (when (file-exists-p npm-tsserver)
         npm-tsserver))
     ;; pnpm layout
     (let ((pnpm-dir (expand-file-name "node_modules/.pnpm" root)))
       (when (file-directory-p pnpm-dir)
         (car (directory-files-recursively
               pnpm-dir
               "node_modules/typescript/lib/tsserver\\.js$"
               nil)))))))

(defun m/typescript-eglot-contact (_interactive project)
  "Build Eglot contact for TypeScript buffers in PROJECT."
  (let* ((typescript-language-server
          (or (m/find-project-bin "typescript-language-server" project)
              (executable-find "typescript-language-server")))
         (tsserver-path (m/find-project-tsserver project)))
    (when typescript-language-server
      (if tsserver-path
          (list typescript-language-server
                "--stdio"
                :initializationOptions
                `(:tsserver (:path ,tsserver-path)))
        (list typescript-language-server "--stdio")))))

(defun m/maybe-typescript-eglot ()
  "Start Eglot only when the current project looks like a TS/JS project."
  (when (m/typescript-project-p)
    (eglot-ensure)))

(use-package eglot
  :ensure nil

  :custom
  (eglot-events-buffer-size 0)
  (eglot-sync-connect nil)
  (eglot-autoshutdown t)
  (eglot-send-changes-idle-time 0.5)

  :hook (typescript-ts-mode . m/maybe-typescript-eglot)

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

  (setf (alist-get 'typescript-ts-mode eglot-server-programs)
        #'m/typescript-eglot-contact))
