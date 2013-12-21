(require-package 'projectile)

(projectile-global-mode)

(setq projectile-completion-system 'grizzl
      projectile-enable-caching t
      projectile-tags-command "ripper-tags -R -f TAGS")

(add-hook 'enh-ruby-mode-hook 'projectile-on)
