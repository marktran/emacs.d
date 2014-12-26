(use-package projectile
  :ensure t
  :diminish projectile-mode
  :idle (projectile-global-mode)
  :config
  (add-hook 'enh-ruby-mode-hook 'projectile-mode)
  (setq projectile-completion-system 'grizzl
        projectile-enable-caching t
        projectile-ignored-projects '("emacs.d" "color-theme-ujelly")
        projectile-tags-command "ripper-tags -R -f TAGS"))

(use-package helm-projectile
  :ensure t)
