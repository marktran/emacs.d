(use-package smartparens
  :ensure t
  :diminish smartparens-mode

  :init
  (require 'smartparens-config)

  :custom
  (sp-highlight-pair-overlay nil)
  (sp-show-pair-delay 0)
  (sp-show-pair-from-inside t)
  (sp-cancel-autoskip-on-backward-movement nil))
