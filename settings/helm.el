(use-package helm
  :commands (helm-mode
             helm-buffers
             helm-find-files
             helm-recentf)

  :bind (:map helm-map
              ("RET" . helm-maybe-exit-minibuffer)
              ("<tab>" . helm-select-action)
              ("C-i" . helm-select-action))
  :bind (:map helm-find-files-map
              ("RET" . helm-execute-persistent-action)
              ("DEL" . dwim-helm-find-files-up-one-level-maybe)
              ("<tab>" . helm-select-action)
              ("C-i" . helm-select-action))
  :bind (:map helm-read-file-map
              ("RET" . helm-execute-persistent-action)
              ("DEL" . dwim-helm-find-files-up-one-level-maybe)
              ("<tab>" . helm-select-action)
              ("C-i" . helm-select-action))

  :config
  (helm-mode 1)

  (setq helm-buffers-fuzzy-matching t
        helm-display-header-line nil
        helm-ff-transformer-show-only-basename nil
        helm-ls-git-show-abs-or-relative 'relative
        helm-M-x-fuzzy-match t
        helm-move-to-line-cycle-in-source t
        helm-recentf-fuzzy-match t
        helm-split-window-in-side-p t)

  (use-package helm-buffers
    :ensure nil
    :config
    (add-to-list 'helm-boring-buffer-regexp-list "\\*eshell"))

  (advice-add 'helm-execute-persistent-action
              :around #'dwim-helm-find-files-navigate-forward))

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
