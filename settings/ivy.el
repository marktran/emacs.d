(use-package ivy
  :diminish ivy-mode
  :init
  (ivy-mode 1)

  :config
  (use-package counsel)
  (use-package flx)
  (use-package swiper)

  (setq ivy-fixed-height-minibuffer t
        ivy-height 20

        ivy-ignore-buffers `("^\\*Compile-Log\\*"
                             "^\\*Completions\\*"
                             "^\\*Help\\*"
                             "^\\*Messages\\*"
                             "^\\*Warnings\\*"
                             "^\\*magit"
                             (lambda (name)
                               (save-excursion
                                 (equal major-mode 'dired-mode))))

        ivy-re-builders-alist '((t . ivy--regex-fuzzy))))
