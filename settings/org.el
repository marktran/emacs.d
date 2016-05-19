(use-package org
  :mode ("\\.org\\'" . org-mode)

  :config
  (setq org-completion-use-ido t
        org-log-done 'time))
