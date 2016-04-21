(use-package ido
  :init
  (setq ido-auto-merge-work-directories-length 1
        ido-create-new-buffer 'always
        ido-enable-flex-matching t
        ido-ignore-buffers `("\\` "
                             "^\\*Buffer List\\*"
                             "^\\*Compile-Log\\*"
                             "^\\*Completions\\*"
                             "^\\*Helm"
                             "^\\*Help\\*"
                             "^\\*Ido"
                             "^\\*Messages\\*"
                             "^\\*RE-Builder\\*"
                             "^\\*Shell Command Output\\*"
                             "^\\*Warnings\\*"
                             "^\\*XML Validation Header\\*"
                             "^\\*growl\\*"
                             "^\\*helm"
                             "^\\*magit"
                             "TAGS"
                             (lambda (name)
                               (save-excursion
                                 (equal major-mode 'dired-mode))))
        ido-use-filename-at-point nil
        ido-use-virtual-buffers nil)

  :config
  (add-to-list 'ido-ignore-files "\\.DS_Store")
  (add-to-list 'ido-ignore-files "Icon$")

  (add-hook 'ido-setup-hook
            (gen-fill-keymap-hook ido-completion-map
                                  "C-h" 'ido-prev-match
                                  "C-l" 'ido-next-match))

  (ido-mode t))

(use-package ido-occasional)
