;; auto refresh buffers
;; http://whattheemacsd.com//sane-defaults.el-01.html
(use-package auto-revert
  :ensure nil
  :diminish auto-revert

  :init
  (global-auto-revert-mode 1)

  :config
  (setq auto-revert-verbose nil
        global-auto-revert-non-file-buffers t))
