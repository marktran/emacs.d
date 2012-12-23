(autoload 'markdown-mode "markdown-mode" nil t)
(setq auto-mode-alist (cons '("\\.md$" . markdown-mode) auto-mode-alist))
