(use-package org
  :ensure nil

  :custom
  (org-default-notes-file "~/Dropbox/org/now/inbox.org")
  (org-log-done 'time)
  (org-src-fontify-natively t)

  (org-capture-templates
   '(("t" "Task" entry (file org-default-notes-file)
      "* TODO %?\n  %U\n  %a\n  %i")))

  (org-agenda-files '("~/Dropbox/org/now/inbox.org"))

  :hook
  (org-mode . visual-line-mode)

  :general
  (:keymaps 'org-mode-map
   :states 'normal
   "za" 'org-cycle
   "zA" 'org-shifttab
   "zc" 'outline-hide-subtree
   "zm" 'outline-hide-body
   "zo" 'outline-show-subtree
   "zr" 'outline-show-all
   "RET" 'org-open-at-point
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup)
  (:keymaps 'org-mode-map
   :states 'visual
   "s-v" 'org-insert-link-dwim)
  (:keymaps 'org-mode-map
   :states 'insert
   "s-v" 'org-yank-dwim
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup)

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
