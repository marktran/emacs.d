(use-package helm
  :config
  (setq helm-buffers-fuzzy-matching t
        helm-display-header-line nil
        helm-ff-transformer-show-only-basename nil
        helm-idle-delay 0.1
        helm-input-idle-delay 0.1
        helm-ls-git-show-abs-or-relative 'relative
        helm-M-x-fuzzy-match t
        helm-move-to-line-cycle-in-source t
        helm-recentf-fuzzy-match t
        helm-split-window-in-side-p t))

(use-package helm-ag
  :config
  (setq helm-ag-insert-at-point 'symbol))

(use-package swiper-helm
  :config
  (setq swiper-helm-display-function 'helm-default-display-buffer))
