(use-package web-mode
  :defer t
  :mode
  (("\\.erb\\'" . web-mode)
   ("\\.html?\\'" . web-mode))

  :config
  (setq web-mode-code-indent-offset 2
        web-mode-markup-indent-offset 2)

  (evil-declare-key 'normal web-mode-map (kbd "%") 'web-mode-tag-match)

  (add-hook 'web-mode-hook 'emmet-mode))
