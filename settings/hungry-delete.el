(use-package hungry-delete
  :ensure t

  :diminish hungry-delete-mode
  :config
  (add-to-list 'hungry-delete-except-modes 'org-mode)
  (global-hungry-delete-mode))
