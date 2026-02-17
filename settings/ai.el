(use-package gptel
  :ensure t

  :config
  (gptel-make-openai "OpenAI"
    :stream t
    :key #'gptel-api-key-from-auth-source
    :models (gptel-backend-models (gptel-get-backend "ChatGPT")))
  (gptel-make-anthropic "Claude"
    :stream t
    :key #'gptel-api-key-from-auth-source)

  (setq gptel-backend (gptel-get-backend "OpenAI")
        gptel-model 'gpt-5.2))
