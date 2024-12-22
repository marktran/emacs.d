(defun project-eat-shell ()
  "Open an `eat-mode` shell in the project root directory."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (eat)))

(use-package project
  :ensure nil)

(use-package disproject
  :ensure t

  :custom
  (disproject-shell-command 'project-eat-shell)

  :config
  (general-define-key
   :prefix "SPC"
   "p" 'disproject-dispatch))
