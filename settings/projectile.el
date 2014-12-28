(use-package projectile
  :ensure t
  :idle (projectile-global-mode)
  :config
  (add-hook 'enh-ruby-mode-hook 'projectile-mode)
  (setq projectile-enable-caching t
        projectile-globally-ignored-buffers '("*eshell*"
                                              "*helm projectile*"
                                              "*magit-process*"
                                              "TAGS")
        projectile-globally-ignored-files '("TAGS")
        projectile-ignored-projects '("~/src/mark/color-theme-ujelly/"
                                      "~/src/mark/emacs.d/")
        projectile-switch-project-action 'helm-projectile-find-file
        projectile-tags-command "ripper-tags -R -f TAGS"))

(use-package helm-projectile
  :ensure t)
