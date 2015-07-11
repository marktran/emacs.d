(use-package company
  :ensure t

  :config
  (setq company-idle-delay 0.2)
  (eval-after-load 'company '(add-to-list 'company-backends 'company-inf-ruby))
  (add-hook 'enh-ruby-mode-hook 'company-mode))

(use-package company-inf-ruby :ensure t)
