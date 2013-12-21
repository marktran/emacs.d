(require-package 'projectile)

(setq projectile-completion-system 'grizzl
      projectile-enable-caching t)

(add-hook 'enh-ruby-mode-hook 'projectile-on)
