(require-package 'company)
(require-package 'company-inf-ruby)

(setq company-idle-delay 0.2)

(eval-after-load 'company
  '(add-to-list 'company-backends 'company-inf-ruby))

(add-hook 'enh-ruby-mode-hook 'company-mode)
