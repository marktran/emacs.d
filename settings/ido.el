(ido-mode t)
(ido-ubiquitous t)

(setq ido-create-new-buffer 'always
      ido-enable-flex-matching t
      ido-everywhere t
      ido-ignore-buffers `("\\` "
                           "^\\*Compile-Log\\*"
                           "^\\*Completions\\*"
                           "^\\*growl\\*"
                           "^\\*Help\\*"
                           "^\\*Ido"
                           "^\\*IPython"
                           "^\\*Messages\\*"
                           "^\\*magit"
                           "^\\*Pymacs\\*"
                           "^\\*Python Output\\*"
                           "^\\*RE-Builder\\*"
                           "^\\*Shell Command Output\\*"
                           "^\\*XML Validation Header\\*"
                           "^Dired:"
                           ,(lambda (name)
                              (if (derived-mode-p 'erc-mode)
                                  (with-current-buffer name
                                    (not (derived-mode-p 'erc-mode)))
                                (with-current-buffer name
                                  (derived-mode-p 'erc-mode)))))
      ido-use-filename-at-point nil)

(add-to-list 'ido-ignore-files "\\.DS_Store")

(add-hook 'ido-setup-hook
          (gen-fill-keymap-hook ido-completion-map
                                "C-h" 'ido-prev-match
                                "C-l" 'ido-next-match))
