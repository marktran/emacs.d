(use-package yasnippet
  :diminish yas-minor-mode
  :mode ("\\.yasnippet\\'" . snippet-mode)

  :init
  (yas-global-mode 1)

  :config
  (setq yas-prompt-functions 'yas-completing-prompt
        yas-use-menu 'abbreviate
        yas-verbosity 0))
