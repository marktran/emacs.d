(use-package project
  :ensure nil
  :general
  (:prefix "SPC p"
   "" '(:ignore t :which-key "Project")
   "b" 'consult-project-buffer))
