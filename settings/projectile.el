(use-package projectile
  :ensure projectile
  :diminish projectile-mode
  :idle (projectile-global-mode)
  :config
  (add-hook 'enh-ruby-mode-hook 'projectile-mode)
  (setq projectile-completion-system 'grizzl
        projectile-enable-caching t
        projectile-tags-command "ripper-tags -R -f TAGS"))
