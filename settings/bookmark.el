(use-package bookmark
  :ensure nil

  :custom
  (bookmark-default-file "~/.emacs.d/.bookmarks")

  :hook
  (bookmark-after-jump . end-of-buffer))
