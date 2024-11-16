(use-package magit
  :hook
  (magit-blame-mode-hook . evil-normalize-keymaps)

  :custom
  (magit-auto-revert-mode nil)
  (magit-bury-buffer-function #'magit-restore-window-configuration)
  (magit-completing-read-function 'completing-read)
  (magit-prefer-remote-upstream t)
  (magit-push-always-verify nil)
  (magit-remote-ref-format 'remote-slash-name)
  (magit-revert-buffers 'silent)

  (magit-display-buffer-function
        (lambda (buffer)
          (if (or
               magit-display-buffer-noselect
               (and (derived-mode-p 'magit-mode)
                    (not (memq (with-current-buffer buffer major-mode)
                               '(magit-process-mode
                                 magit-revision-mode
                                 magit-diff-mode
                                 magit-stash-mode
                                 magit-status-mode)))))
              (magit-display-buffer-traditional buffer)
            (delete-other-windows)
            (set-window-dedicated-p nil nil)
            (set-window-buffer nil buffer)
            (get-buffer-window buffer))))

  :general
  (:prefix "SPC g"
   ""  '(:ignore t :which-key "Magit")
   "b" '(magit-blame :which-key "Blame")
   "l" '(magit-log-current :which-key "Log")
   "L" '(magit-log-buffer-file :which-key "Log [for file]")
   "s" '(magit-status :which-key "Status"))

  :config
  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'magit-popup-mode 'emacs)
  (evil-set-initial-state 'magit-popup-sequence-mode 'emacs)
  (evil-set-initial-state 'magit-refs-mode 'emacs)
  (evil-set-initial-state 'magit-revision-mode 'emacs)

  (add-to-list 'magit-no-confirm 'stage-all-changes))

(use-package forge
  :after magit)
