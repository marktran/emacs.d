(use-package whitespace-cleanup-mode
  :defer t
  :diminish whitespace-cleanup-mode

  :config
  (setq-default show-trailing-whitespace t)
  (global-whitespace-cleanup-mode t)

  (dolist (hook '(comint-mode-hook
                  compilation-mode-hook
                  eshell-mode-hook
                  help-mode-hook
                  vc-annotate-mode-hook))
    (add-hook hook (lambda () (setq show-trailing-whitespace nil)))))
