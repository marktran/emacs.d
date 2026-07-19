(use-package embark
  :ensure t

  :general
  (:keymaps 'global
   "C-." 'embark-act)
  (:states '(normal visual)
   :keymaps 'global
   "g." 'embark-act
   "gx" 'embark-dwim)

  :config
  ;; Ghostel, not eshell, is the resident terminal: retarget Embark's
  ;; "open a shell here" action. The hooks mirror Embark's eshell setup:
  ;; a simulated C-u forces a fresh terminal, and `embark--cd' starts it
  ;; in the target's directory.
  (dolist (map (list embark-file-map embark-buffer-map
                     embark-library-map embark-bookmark-map))
    (keymap-set map "$" #'ghostel))
  (add-to-list 'embark-pre-action-hooks '(ghostel embark--universal-argument))
  (add-to-list 'embark-around-action-hooks '(ghostel embark--cd)))

(use-package embark-consult
  :ensure t)
