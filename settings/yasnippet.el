(add-to-list 'auto-mode-alist '("\\.yasnippet$" . snippet-mode))

(setq yas-prompt-functions '(yas/ido-prompt)
      yas-use-menu 'abbreviate
      yas-verbosity 0)

(yas-global-mode t)
