(use-package smartparens
  :ensure t
  :diminish smartparens-mode

  :config
  (require 'smartparens-config)
  (require 'smartparens-ruby)

  (setq sp-show-pair-delay 0
        sp-show-pair-from-inside t
        sp-cancel-autoskip-on-backward-movement nil)

  (smartparens-global-mode)
  (show-smartparens-global-mode))
