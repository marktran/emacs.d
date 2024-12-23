(use-package org
  :ensure nil

  :custom
  (org-log-done 'time)
  (org-src-fontify-natively t)

  :hook
  (org-mode . visual-line-mode)

  :general
  (:keymaps 'org-mode-map
   :states 'normal
   :prefix "SPC m"
   "" '(:ignore t :which-key "Org")
   "l" '(org-insert-link :which-key "Insert link")
   "t" '(m/org-insert-todo-heading :which-key "Insert todo heading"))

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
   :states 'insert
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup))

(use-package org-autolist
  :ensure t
  :after org
  :diminish org-autolist-mode

  :hook
  (org-mode . org-autolist-mode))

(use-package evil-org
  :ensure t
  :after org
  :diminish evil-org-mode

  :hook
  (org-mode . evil-org-mode)

  :config
  (evil-org-set-key-theme))

(use-package consult-denote
  :ensure t

  :config
  (consult-denote-mode))

(use-package consult-notes
  :ensure t

  :config
  (consult-notes-denote-mode))

(use-package denote
  :ensure t

  :custom
  (denote-directory (expand-file-name "~/Documents/denote"))
  (denote-dired-directories-include-subdirectories t)
  (denote-known-keywords '("meeting" "person"))
  (denote-rename-buffer-mode t)

  :hook
  (dired-mode . denote-dired-mode-in-directories)

  :general
  (:prefix "SPC n"
   "" '(:ignore t :which-key "Notes")
   "c" '(denote-create-note :which-key "Create note")
   "d" '(denote-journal-extras-new-or-existing-entry :which-key "Jump to daily entry")
   "f" '(consult-notes :which-key "Find notes")
   "s" '(consult-denote-grep :which-key "Search notes"))

  :config
  (setq denote-dired-directories (list denote-directory)))

(use-package denote-journal-extras
  :ensure nil

  :custom
  (denote-journal-extras-directory (expand-file-name "journal" denote-directory))
  (denote-journal-extras-title-format 'day-date-month-year))
