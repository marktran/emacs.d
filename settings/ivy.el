(use-package ivy
  :diminish ivy-mode
  :init
  (ivy-mode 1)

  :config
  (setq ivy-extra-directories nil
        ivy-fixed-height-minibuffer t
        ivy-height 20

        ivy-ignore-buffers `("^\\*alchemist-server\\*"
                             "^\\*alchemist test report\\*"
                             "^\\*Compile-Log\\*"
                             "^\\*Completions\\*"
                             "^\\*Flycheck errors\\*"
                             "^\\*Help\\*"
                             "^\\*Messages\\*"
                             "^\\*Warnings\\*"
                             "^\\*eshell"
                             "^\\*magit"
                             "^\\*scratch\\*"
                             "^\\*rspec-compilation\\*"
                             (lambda (name)
                               (save-excursion
                                 (equal major-mode 'dired-mode))))

        ivy-re-builders-alist '((t . ivy--regex-fuzzy))
        ivy-use-selectable-prompt t))

(use-package counsel
  :after ivy
  :config
  (setq counsel-find-file-ignore-regexp "\\.DS_Store\\|\\.gitkeep"))

(use-package flx
  :after counsel)

(use-package swiper
  :after counsel)
