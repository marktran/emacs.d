(defun project-eat-shell ()
  "Open an `eat-mode` shell in the project root directory."
  (interactive)
  (let ((default-directory (project-root (project-current t))))
    (eat)))

(use-package project
  :ensure nil

  :general
  (:prefix "SPC p"
   "" '(:ignore t :which-key "Project")
   "b" 'consult-project-buffer
   "D" 'project-dired
   "s" 'project-eat-shell))
