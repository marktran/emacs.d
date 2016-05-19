(use-package company
  :diminish company-mode
  :config
  (use-package company-inf-ruby
    :init (add-to-list 'company-backends 'company-inf-ruby))

  (setq company-idle-delay 0.2))
