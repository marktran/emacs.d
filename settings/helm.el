(use-package helm
  :ensure t

  :config
  (setq helm-buffers-fuzzy-matching t
        helm-ff-transformer-show-only-basename nil
        helm-idle-delay 0.1
        helm-input-idle-delay 0.1
        helm-ls-git-show-abs-or-relative 'relative
        helm-M-x-fuzzy-match t
        helm-move-to-line-cycle-in-source t
        helm-recentf-fuzzy-match t))

(use-package helm-ag :ensure t)

(use-package helm-swoop
  :ensure t

  :init
  (setq helm-swoop-pre-input-function (lambda () "")
        helm-swoop-split-with-multiple-windows t))
