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
    (seq-some (lambda (name)
                (file-exists-p (expand-file-name name root)))
              '("tsconfig.json" "jsconfig.json" "package.json"
                "deno.json" "deno.jsonc"))))

(defun m/find-project-tsserver (&optional project)
  "Find a project-local tsserver.js path for PROJECT."
  (when-let* ((root (m/project-root project)))
    (or
     ;; npm/yarn layout
     (when-let* ((tsserver (expand-file-name
                            "node_modules/typescript/lib/tsserver.js" root))
                 ((file-exists-p tsserver)))
       tsserver)
     ;; pnpm layout
     (when-let* ((pnpm-dir (expand-file-name "node_modules/.pnpm" root))
                 ((file-directory-p pnpm-dir)))
       (car (directory-files-recursively
             pnpm-dir "node_modules/typescript/lib/tsserver\\.js$"))))))

(defun m/typescript-eglot-contact (_interactive project)
  "Build Eglot contact for TypeScript buffers in PROJECT."
  (when-let* ((server (or (m/find-project-bin "typescript-language-server" project)
                          (executable-find "typescript-language-server"))))
    (let ((tsserver (m/find-project-tsserver project)))
      `(,server "--stdio"
        ,@(when tsserver
            `(:initializationOptions (:tsserver (:path ,tsserver))))))))

(defun m/maybe-typescript-eglot ()
  "Start Eglot only when the current project looks like a TS/JS project."
  (when (m/typescript-project-p)
    (eglot-ensure)))

(defun m/eglot-booster-wrap (entry)
  "Prefix ENTRY's command with emacs-lsp-booster when it is a command list.
ENTRY is an element of `eglot-server-programs'; function contacts are
returned unchanged."
  (if (and (consp entry) (listp (cdr entry)))
      (cons (car entry)
            (append '("emacs-lsp-booster" "--verbose") (cdr entry)))
    entry))

(use-package eglot
  :ensure nil

  :custom
  (eglot-events-buffer-config '(:size 0))
  (eglot-sync-connect nil)
  (eglot-autoshutdown t)
  (eglot-send-changes-idle-time 0.5)

  :hook (typescript-ts-mode . m/maybe-typescript-eglot)

  :config
  ;; Wrap plain command contacts with emacs-lsp-booster; function
  ;; contacts (like the TypeScript one below) are left as-is.
  (when (executable-find "emacs-lsp-booster")
    (setq eglot-server-programs
          (mapcar #'m/eglot-booster-wrap eglot-server-programs)))

  (setf (alist-get 'typescript-ts-mode eglot-server-programs)
        #'m/typescript-eglot-contact))
