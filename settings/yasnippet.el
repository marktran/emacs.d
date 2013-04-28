(setq yas-prompt-functions '(yas/ido-prompt)
      yas-use-menu 'abbreviate
      yas-verbosity 0)

(define-key yas-minor-mode-map (kbd "<backtab>") 'yas/expand)
(define-key yas-minor-mode-map (kbd "TAB") nil)

(yas-global-mode t)
