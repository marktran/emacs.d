(require-package 'yasnippet)

(add-auto-mode 'snippet-mode "\\.yasnippet\\'")

(setq yas-prompt-functions '(yas/ido-prompt)
      yas-use-menu 'abbreviate
      yas-verbosity 0)

(yas-global-mode t)
