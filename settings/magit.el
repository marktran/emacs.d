(use-package magit
  :commands (magit-blame
             magit-log-buffer-file
             magit-log-current
             magit-status)

  :config
  (use-package evil-magit)

  (setq magit-auto-revert-mode nil
        magit-branch-arguments (remove "--track" magit-branch-arguments)
        magit-completing-read-function 'magit-ido-completing-read

        magit-display-buffer-function
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
            (get-buffer-window buffer)))

        magit-push-always-verify nil
        magit-remote-ref-format 'remote-slash-name
        magit-revert-buffers 'silent
        vc-handled-backends nil)

  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'magit-popup-mode 'emacs)
  (evil-set-initial-state 'magit-popup-sequence-mode 'emacs)
  (evil-set-initial-state 'magit-refs-mode 'emacs)
  (evil-set-initial-state 'magit-revision-mode 'emacs)

  (evil-make-overriding-map magit-blame-mode-map 'normal)
  (add-to-list 'magit-no-confirm 'stage-all-changes)
  (add-hook 'magit-blame-mode-hook 'evil-normalize-keymaps))
