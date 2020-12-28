(use-package smartparens
  :diminish smartparens-mode

  :config
  (use-package smartparens-config :ensure smartparens)

  (setq sp-highlight-pair-overlay nil
        sp-show-pair-delay 0
        sp-show-pair-from-inside t
        sp-cancel-autoskip-on-backward-movement nil)

  (sp-with-modes '(elixir-mode)
    (sp-local-pair "->" "end"
                   :when '(("RET"))
                   :post-handlers '(:add sp-elixir-do-end-close-action)
                   :actions '(insert))

    (sp-local-pair "do" "end"
                 :when '(("SPC" "RET"))
                 :post-handlers '(:add sp-elixir-do-end-close-action)
                 :actions '(insert))))
