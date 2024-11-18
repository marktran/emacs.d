(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode

  :custom
  (undo-tree-auto-save-history nil)

  :config
  (global-undo-tree-mode 1)

  ;; Keep region when undoing in a region
  (defun my/undo-tree-keep-region (orig-fn &rest args)
    (if (use-region-p)
        (let ((m (set-marker (make-marker) (mark)))
              (p (set-marker (make-marker) (point))))
          (apply orig-fn args)
          (goto-char p)
          (set-mark m)
          (set-marker p nil)
          (set-marker m nil))
      (apply orig-fn args)))
  (advice-add 'undo-tree-undo :around #'my/undo-tree-keep-region))
