(use-package yasnippet
  :ensure t

  :mode ("\\.yasnippet\\'" . snippet-mode)

  :config
  (setq yas-prompt-functions '(yas/ido-prompt)
        yas-use-menu 'abbreviate
        yas-verbosity 0)

  (yas-global-mode t))
