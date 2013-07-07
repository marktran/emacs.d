(add-auto-mode 'rhtml-mode "\\.erb\\'")
(add-hook 'rhtml-mode-hook 'emmet-mode)

;; after deleting a tag, indent properly
;; http://whattheemacsd.com/setup-html-mode.el-05.html
(defadvice sgml-delete-tag (after reindent activate)
  (indent-region (point-min) (point-max)))
