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
   "d" 'project-find-dir
   "D" 'project-dired
   "f" 'project-find-file
   "p" 'project-switch-project
   "s" 'project-eat-shell))
