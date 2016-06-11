(use-package projectile
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
  (general-define-key :prefix "SPC"
                      "p" '(:ignore t :which-key "Projectile")
                      "p b" '(projectile-switch-to-buffer :which-key "Switch buffer")
                      "p D" '(projectile-dired :which-key "Dired")
                      "p d" '(projectile-find-dir :which-key "Find directory")
                      "p i" '(projectile-invalidate-cache :which-key "Invalidate cache")
                      "p j" '(projectile-find-tag :which-key "Find tag")
                      "p k" '(projectile-kill-buffers :which-key "Kill [project] buffers")
                      "p p" '(projectile-switch-project :which-key "Switch project")
                      "p R" '(projectile-regenerate-tags :which-key "Regenerate tags")
                      "p r" '(projectile-recentf :which-key "Recent [project] files")
                      "p s" '(projectile-run-eshell :which-key "Eshell"))

  (projectile-global-mode 1))
