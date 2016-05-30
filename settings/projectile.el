(use-package projectile
  :commands
  (projectile-dired
   projectile-find-dir
   projectile-find-tag
   projectile-kill-buffers
   projectile-invalidate-cache
   projectile-regenerate-tags
   projectile-run-eshell
   projectile-switch-to-buffer)

  :init
  (add-hook 'enh-ruby-mode-hook 'projectile-mode)

  (setq projectile-completion-system 'ivy
        projectile-enable-caching t
        projectile-globally-ignored-buffers '("*Helm Find Files*"
                                              "*eshell*"
                                              "*helm M-x*"
                                              "*helm projectile*"
                                              "*helm recentf*"
                                              "*magit-process*"
                                              "TAGS")
        projectile-globally-ignored-files '("TAGS")
        projectile-ignored-projects '("/usr/local"
                                      "~/src/mark/color-theme-ujelly/"
                                      "~/src/mark/emacs.d/")
        projectile-mode-line '(:eval (format " P/%s" (projectile-project-name)))
        projectile-switch-project-action 'helm-projectile-find-file
        projectile-tags-command "ripper-tags -R -f TAGS")

  :config
  (projectile-global-mode))
