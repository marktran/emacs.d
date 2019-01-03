(use-package web-mode
  :mode
  (("\\.erb\\'" . web-mode)
   ("\\.html?\\'" . web-mode)
   ("\\.tsx\\'" . web-mode))

  :hook (web-mode . (lambda ()
                      (when (and (buffer-file-name)
                                 (string-equal "tsx" (file-name-extension (buffer-file-name))))
                        (tide-setup)
                        (flycheck-mode 1)
                        (eldoc-mode 1))))

  :config
  (setq-default web-mode-comment-formats
                '(("javascript" . "//")))

  (setq web-mode-code-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-enable-css-colorization t
        web-mode-markup-indent-offset 2
        web-mode-script-padding 2
        web-mode-style-padding 2)

  (evil-declare-key 'normal web-mode-map (kbd "%") 'web-mode-tag-match))
