;; Auto refresh buffers.
;; http://whattheemacsd.com//sane-defaults.el-01.html
(use-package autorevert
  :ensure nil

  :custom
  (auto-revert-verbose nil)
  (global-auto-revert-non-file-buffers t)

  :config
  (global-auto-revert-mode 1))
