(use-package undo-tree
  :diminish undo-tree-mode
  :init (global-undo-tree-mode 1))

;; keep region when undoing in region
;; http://whattheemacsd.com/my-misc.el-02.html
(defadvice undo-tree-undo (around keep-region activate)
  (if (use-region-p)
      (let ((m (set-marker (make-marker) (mark)))
            (p (set-marker (make-marker) (point))))
        ad-do-it
        (goto-char p)
        (set-mark m)
        (set-marker p nil)
        (set-marker m nil))
    ad-do-it))
