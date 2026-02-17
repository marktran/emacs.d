(use-package flymake
  :ensure nil

  :init
  (remove-hook 'flymake-diagnostic-functions #'flymake-proc-legacy-flymake))
