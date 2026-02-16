(use-package org
  :ensure nil

  :custom
  (org-default-notes-file "~/Dropbox/org/now/inbox.org")

  (org-capture-templates
   '(("t" "Task" entry (file org-default-notes-file)
      "* TODO %?\n  %U\n  %a\n  %i")))

  (org-agenda-files '("~/Dropbox/org/now/inbox.org"))

  :config
  (defun m/org-agenda-hide-ddl-and-grid (&rest _)
    "Hide Ddl and Grid status markers from the org-agenda mode line."
    (when (and (eq major-mode 'org-agenda-mode)
               (listp mode-name))
      (let (cleaned)
        (dolist (part mode-name)
          (unless (member part '(" Ddl" " Grid"))
            (push part cleaned)))
        (setq mode-name (nreverse cleaned))
        (force-mode-line-update))))

  (with-eval-after-load 'org-agenda
    (advice-add 'org-agenda-set-mode-name :after #'m/org-agenda-hide-ddl-and-grid)))
