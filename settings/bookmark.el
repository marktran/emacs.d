(use-package bookmark
  :ensure nil

  :init
  (setq bookmark-default-file "~/.emacs.d/.bookmarks")

  :hook
  (bookmark-after-jump . end-of-buffer))
