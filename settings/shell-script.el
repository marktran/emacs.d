(use-package sh-script
  :ensure nil

  :custom
  (sh-basic-offset 2)

  :hook
  (after-save . executable-make-buffer-file-executable-if-script-p))
