(use-package ruby-mode
  :ensure nil)

(use-package ruby-end
  :ensure t
  :diminish

  :custom
  (ruby-end-insert-newline nil)

  :hook
  (ruby-mode . ruby-end-mode))
