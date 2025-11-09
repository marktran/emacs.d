(use-package org
  :ensure nil

  :custom
  (org-default-notes-file "~/Dropbox/org/now/inbox.org")

  (org-capture-templates
   '(("t" "Task" entry (file org-default-notes-file)
      "* TODO %?\n  %U\n  %a\n  %i")))

  (org-agenda-files '("~/Dropbox/org/now/inbox.org")))
