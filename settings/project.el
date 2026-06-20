(defun project-ghostel-shell ()
  "Open a `ghostel-mode` terminal in the project root directory."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (ghostel)))

(use-package project
  :ensure nil)

(use-package disproject
  :ensure t

  :custom
  (disproject-shell-command 'project-ghostel-shell))
