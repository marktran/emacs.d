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
   "." '(project-dired :which-key "Dired")
   "b" '(consult-project-buffer :which-key "Switch Buffer")
   "d" '(project-find-dir :which-key "Find Directory")
   "f" '(project-find-file :which-key "Find File")
   "p" '(project-switch-project :which-key "Switch Project")
   "s" '(project-eat-shell :which-key "Shell")))
