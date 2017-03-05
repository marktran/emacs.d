(use-package hungry-delete
  :diminish hungry-delete-mode
  :config
  (add-to-list 'hungry-delete-except-modes 'org-mode)
  (global-hungry-delete-mode))
