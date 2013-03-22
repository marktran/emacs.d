(ido-mode t)
(ido-ubiquitous t)

(setq ido-auto-merge-work-directories-length 1
      ido-case-fold nil
      ido-create-new-buffer 'always
      ido-enable-flex-matching t
      ido-everywhere t
      ido-ignore-buffers `("\\` "
                           "^\\*Buffer List\\*"
                           "^\\*Compile-Log\\*"
                           "^\\*Completions\\*"
                           "^\\*growl\\*"
                           "^\\*helm"
                           "^\\*Helm"
                           "^\\*Help\\*"
                           "^\\*Ido"
                           "^\\*Messages\\*"
                           "^\\*magit"
                           "^\\*RE-Builder\\*"
                           "^\\*Shell Command Output\\*"
                           "^\\*XML Validation Header\\*"
                           "^Dired:")
      ido-use-filename-at-point nil
      ido-use-virtual-buffers t)

(add-to-list 'ido-ignore-files "\\.DS_Store")

(add-hook 'ido-setup-hook
          (gen-fill-keymap-hook ido-completion-map
                                "C-h" 'ido-prev-match
                                "C-l" 'ido-next-match))
