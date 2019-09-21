(use-package magit
  :custom
  (magit-auto-revert-mode nil)
  (magit-completing-read-function 'ivy-completing-read)
  (magit-prefer-remote-upstream t)
  (magit-push-always-verify nil)
  (magit-remote-ref-format 'remote-slash-name)
  (magit-revert-buffers 'silent)
  (vc-handled-backends nil)

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

  :config
  (general-define-key :prefix "SPC"
   "g"  '(:ignore t :which-key "Magit")
   "g b" '(magit-blame :which-key "Blame")
   "g l" '(magit-log-current :which-key "Log")
   "g L" '(magit-log-buffer-file :which-key "Log [for file]")
   "g s" '(magit-status :which-key "Status"))

  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'magit-popup-mode 'emacs)
  (evil-set-initial-state 'magit-popup-sequence-mode 'emacs)
  (evil-set-initial-state 'magit-refs-mode 'emacs)
  (evil-set-initial-state 'magit-revision-mode 'emacs)

  (add-to-list 'magit-no-confirm 'stage-all-changes)
  (add-hook 'magit-blame-mode-hook 'evil-normalize-keymaps))

(use-package evil-magit
  :after magit)

(use-package forge
  :after magit)
