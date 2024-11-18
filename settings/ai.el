(use-package gptel
  :ensure t

  :custom
  (gptel-model 'claude-3-sonnet-20240229)

  :config
  (setq gptel-backend (gptel-make-anthropic "Claude"
                        :stream t
                        :key (getenv "ANTHROPIC_API_KEY"))))
