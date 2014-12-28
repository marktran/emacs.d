(require-package 'helm)

(setq helm-ff-transformer-show-only-basename nil
      helm-idle-delay 0.1
      helm-input-idle-delay 0.1
      helm-ls-git-show-abs-or-relative 'relative
      helm-M-x-fuzzy-match t
      helm-move-to-line-cycle-in-source t)
