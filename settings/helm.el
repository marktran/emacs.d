(use-package helm
  :demand
  :bind
  (:map helm-map
        ("<tab>" . helm-execute-persistent-action)
        ("C-i" . helm-execute-persistent-action)
        ("C-z" . helm-select-action))

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
        helm-split-window-in-side-p t)

(use-package helm-buffers
  :ensure nil
  :defer t
  :config
  (add-to-list 'helm-boring-buffer-regexp-list "\\*eshell")))

(use-package helm-ag
  :commands (helm-ag-project-root)

  :config
  (setq helm-ag-insert-at-point 'symbol))

(use-package helm-descbinds
  :commands (helm-descbinds))

(advice-add 'helm-ff-filter-candidate-one-by-one
        :around (lambda (fcn file)
                  (unless (string-match "\\(?:/\\|\\`\\)\\.\\{1,2\\}\\'" file)
                    (funcall fcn file))))
