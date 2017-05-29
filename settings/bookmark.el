(use-package bookmark
  :ensure nil
  :defer t
  :config
  (setq bookmark-default-file "~/.emacs.d/.bookmarks")

  (add-hook 'bookmark-after-jump-hook 'end-of-buffer))
