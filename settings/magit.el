(use-package magit
  :ensure t

  :config
  (setq magit-auto-revert-mode nil
        magit-branch-arguments (remove "--track" magit-branch-arguments)
        magit-completing-read-function 'magit-ido-completing-read
        magit-push-always-verify "PP"
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
  (add-hook 'magit-blame-mode-hook 'evil-normalize-keymaps))


(defadvice magit-log-current (around magit-fullscreen activate)
  ad-do-it
  (delete-other-windows))

(defadvice magit-log-buffer-file (around magit-fullscreen activate)
  ad-do-it
  (delete-other-windows))
