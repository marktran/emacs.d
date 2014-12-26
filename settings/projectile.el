(use-package projectile
  :ensure t
  :diminish projectile-mode
  :idle (projectile-global-mode)
  :config
  (add-hook 'enh-ruby-mode-hook 'projectile-mode)
  (setq projectile-completion-system 'grizzl
        projectile-enable-caching t
        projectile-ignored-projects '("~/src/mark/color-theme-ujelly/"
                                      "~/src/mark/emacs.d/")
        projectile-switch-project-action 'helm-projectile-find-file
        projectile-tags-command "ripper-tags -R -f TAGS"))

(use-package helm-projectile
  :ensure t)
