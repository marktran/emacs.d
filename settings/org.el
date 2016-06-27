(use-package org
  :mode ("\\.org\\'" . org-mode)

  :general
  (:keymaps 'org-mode-map
   :states 'normal
   "za" 'org-cycle
   "zA" 'org-shifttab
   "zc" 'hide-subtree
   "zm" 'hide-body
   "zo" 'show-subtree
   "zr" 'show-all

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
   "M-K" 'org-metaup)

  :config
  (setq org-log-done 'time))
