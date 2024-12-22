(use-package org
  :ensure nil

  :custom
  (org-log-done 'time)
  (org-src-fontify-natively t)

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

(use-package evil-org
  :after org

  :hook
  (org-mode . evil-org-mode)

  :config
  (evil-org-set-key-theme))

(use-package denote
  :ensure t)
