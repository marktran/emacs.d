;; http://atomized.org/2010/06/ \
;; resolving-merge-conflicts-the-easy-way-with-smerge-kmacro/
(defun sm-try-smerge ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^<<<<<<< " nil t)
      (smerge-mode 1))))

(add-hook 'find-file-hook 'sm-try-smerge t)
