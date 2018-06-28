(use-package web-mode
  :mode
  (("\\.html?\\'" . web-mode))

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
