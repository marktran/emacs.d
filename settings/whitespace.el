(require-package 'whitespace-cleanup-mode)

(global-whitespace-cleanup-mode t)
(diminish 'whitespace-cleanup-mode)

(setq-default show-trailing-whitespace t)

(dolist (hook '(comint-mode-hook compilation-mode-hook))
  (add-hook hook
            (lambda () (setq show-trailing-whitespace nil))))
