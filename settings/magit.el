(use-package magit
  :ensure t

  :config
  (setq magit-auto-revert-mode nil
        magit-branch-arguments (remove "--track" magit-branch-arguments)
        magit-completing-read-function 'magit-ido-completing-read
        magit-push-always-verify nil
        magit-remote-ref-format 'remote-slash-name
        magit-restore-window-configuration t
        magit-revert-buffers 'silent
        magit-status-buffer-switch-function
        (lambda (buffer)
          (pop-to-buffer buffer)
          (delete-other-windows))
        vc-handled-backends '(git))

  (evil-set-initial-state 'git-commit-mode 'emacs)
  (evil-set-initial-state 'magit-popup-mode 'emacs)
  (evil-set-initial-state 'magit-popup-sequence-mode 'emacs)
  (evil-set-initial-state 'magit-refs-mode 'emacs)
  (evil-set-initial-state 'magit-revision-mode 'emacs)

  (evil-make-overriding-map magit-blame-mode-map 'normal)
  (add-to-list 'magit-no-confirm 'stage-all-changes)
  (add-hook 'magit-blame-mode-hook 'evil-normalize-keymaps))

(setq magit-post-display-buffer-hook
      #'(lambda ()
          (when (derived-mode-p 'magit-status-mode)
            (delete-other-windows))))
