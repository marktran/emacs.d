;;; gptel.el --- LLM chat through the Cloudflare AI Gateway

;; All models are reached through the Cloudflare AI Gateway's
;; OpenAI-compatible endpoint
;; (https://gateway.ai.cloudflare.com/v1/{account}/{gateway}/compat), with
;; provider keys stored in the gateway (BYOK) so a single Cloudflare AI
;; Gateway token authenticates every request. Models use the gateway's
;; `provider/model' naming.
;;
;; The token lives in ~/.authinfo as:
;;
;;   machine gateway.ai.cloudflare.com login apikey password <token>
;;
;; gptel picks it up automatically because the backend host matches the
;; authinfo machine. The token is sent both as the `Authorization' bearer
;; (used by BYOK) and in `cf-aig-authorization' (used when gateway
;; authentication is enabled), which covers either gateway configuration.

(defvar m/gptel-cloudflare-account-id "472017f2a442123c9f8f9da2bb39e5e8"
  "Cloudflare account ID for the AI Gateway.")

(defvar m/gptel-cloudflare-gateway-id "workos"
  "Cloudflare AI Gateway ID.")

(use-package gptel
  :ensure t
  :commands (gptel gptel-send gptel-menu)

  :general
  ("SPC a" '(gptel :which-key "Chat"))

  ;; Soft-wrap long lines in gptel chat buffers. Wide markdown
  ;; tables look broken under soft wrap (continuation lines ruin
  ;; column alignment); use `C-x x t' (`toggle-truncate-lines') in
  ;; the chat buffer to switch to truncated, horizontally-scrollable
  ;; lines when reading tables.
  :hook (gptel-mode . visual-line-mode)

  :config
  ;; Keep pipe tables aligned as responses stream in.
  (add-hook 'gptel-post-response-functions #'m/gptel-align-tables)
  (defun m/gptel-align-tables (beg end)
    "Align markdown tables between BEG and END after a gptel response."
    (when (derived-mode-p 'markdown-mode)
      (save-excursion
        (let ((end (copy-marker end)))
          (goto-char beg)
          (while (and (< (point) end)
                      (re-search-forward "^[ \t]*|.*|[ \t]*$" end t))
            (when (markdown-table-at-point-p)
              (markdown-table-align)
              (goto-char (min (1+ (markdown-table-end)) (point-max)))))
          (set-marker end nil)))))

  (defun m/gptel-cloudflare-header (&optional _info)
    "Authorization headers for the Cloudflare AI Gateway.
Since gptel 0.9.9.5, header functions receive the request context
plist (INFO), which we don't need.  Do not add Content-Type here:
gptel prepends it itself, and a duplicated Content-Type header
makes the gateway reject the request body (400 \"you must provide
a model parameter\")."
    (let ((token (gptel--get-api-key gptel-api-key)))
      `(("Authorization" . ,(concat "Bearer " token))
        ("cf-aig-authorization" . ,(concat "Bearer " token)))))

  (setq gptel-backend
        (gptel-make-openai "Gateway"
          :host "gateway.ai.cloudflare.com"
          :endpoint (format "/v1/%s/%s/compat/chat/completions"
                            m/gptel-cloudflare-account-id
                            m/gptel-cloudflare-gateway-id)
          :stream t
          :key 'gptel-api-key
          :header #'m/gptel-cloudflare-header
          ;; Note: the compat endpoint's provider slug for xAI is
          ;; `grok', not `xai'.
          :models '(openai/gpt-5.6-sol
                    anthropic/claude-fable-5
                    anthropic/claude-opus-5
                    anthropic/claude-sonnet-5
                    grok/grok-4.5))
        gptel-model 'openai/gpt-5.6-sol)

  ;; GLM 5.2 can't be reached through the compat endpoint: the
  ;; `custom-fireworks-ai' Custom Provider's base URL is Fireworks'
  ;; `/inference' root, and compat appends `/chat/completions'
  ;; directly, missing the required `/v1'. Instead, hit the provider
  ;; path directly with the `/v1' included, like Pi does.
  (gptel-make-openai "Cloudflare-Fireworks"
    :host "gateway.ai.cloudflare.com"
    :endpoint (format "/v1/%s/%s/custom-fireworks-ai/v1/chat/completions"
                      m/gptel-cloudflare-account-id
                      m/gptel-cloudflare-gateway-id)
    :stream t
    :key 'gptel-api-key
    :header #'m/gptel-cloudflare-header
    :models '(accounts/fireworks/models/glm-5p2)))
