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

(use-package helm-swoop
  :init
  (setq helm-swoop-pre-input-function (lambda () "")
        helm-swoop-split-with-multiple-windows t))

(defun helm-swoop-region-or-symbol ()
  "Call `helm-swoop' with default input."
  (interactive)
  (let ((helm-swoop-pre-input-function
         (lambda ()
           (if (region-active-p)
               (buffer-substring-no-properties (region-beginning)
                                               (region-end))
             (let ((thing (thing-at-point 'symbol t)))
               (if thing thing ""))))))
    (call-interactively 'helm-swoop)))
