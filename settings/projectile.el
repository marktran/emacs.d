(use-package projectile
  :diminish
  :init
  (setq projectile-completion-system 'default
        projectile-enable-caching t
        projectile-globally-ignored-buffers '("*eshell*"
                                              "*magit-process*"
                                              "TAGS")
        projectile-globally-ignored-files '("TAGS")
        projectile-globally-ignored-file-suffixes '(".gif"
                                                    ".gitkeep"
                                                    ".jpeg"
                                                    ".jpg"
                                                    ".png"
                                                    ".zip")
        projectile-mode-line nil
        projectile-tags-command "ripper-tags -R -f TAGS"
        projectile-track-known-projects-automatically nil)

  :config
  (general-define-key :prefix "SPC"
    "p d" '(projectile-find-dir :which-key "Find directory")
    "p i" '(projectile-invalidate-cache :which-key "Invalidate cache")
    "p j" '(dumb-jump-go :which-key "Dumb jump")
    "p k" '(projectile-kill-buffers :which-key "Kill [project] buffers")
    "p p" '(projectile-switch-project :which-key "Switch project")
    "p R" '(projectile-regenerate-tags :which-key "Regenerate tags")
    "p r" '(projectile-recentf :which-key "Recent [project] files")
    "p t" '(treemacs-projectile :which-key "Treemacs"))

  (projectile-global-mode 1))

(use-package projectile-rails
  :after projectile
  :diminish projectile-rails-mode
  :config
  (projectile-rails-global-mode 1))
