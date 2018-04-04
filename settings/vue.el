(use-package vue-mode
  :mode "\\.vue\\'"

  :general
  (:keymaps 'vue-mode-map
   :states 'normal
   :prefix "SPC"
   "r" '(vue-mode-reparse :which-key "Reparse file")))
