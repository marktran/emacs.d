(use-package backtrace
  :ensure nil

  :hook
  (backtrace-mode . evil-normal-state)

  :general
  (:keymaps 'backtrace-mode-map
   :states 'normal
   "q" 'debugger-quit))
