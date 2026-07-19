(use-package embark
  :ensure t

  :general
  (:keymaps 'global
   "C-." 'embark-act)
  (:states '(normal visual)
   :keymaps 'global
   "g." 'embark-act
   "gx" 'embark-dwim))

(use-package embark-consult
  :ensure t)
