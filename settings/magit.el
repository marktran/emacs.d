(require-package 'magit)

(require 'magit)

(setq magit-auto-revert-mode nil
      magit-completing-read-function 'magit-ido-completing-read
      magit-last-seen-setup-instructions "1.4.0"
      magit-remote-ref-format 'remote-slash-name
      magit-restore-window-configuration t
      vc-handled-backends '(git))

;; full screen vc-annotate
;; https://github.com/magnars/.emacs.d/blob/master/setup-magit.el
(defun vc-annotate-quit ()
  "Restores the previous window configuration and kills the vc-annotate buffer"
  (interactive)
  (kill-buffer)
  (jump-to-register :vc-annotate-fullscreen))

(after-load 'vc-annotate
     (defadvice vc-annotate (around fullscreen activate)
       (window-configuration-to-register :vc-annotate-fullscreen)
       ad-do-it
       (delete-other-windows))
     (define-key vc-annotate-mode-map (kbd "q") 'vc-annotate-quit))

;; full screen magit-status
;; http://whattheemacsd.com/setup-magit.el-01.html
(defadvice magit-status (around magit-fullscreen activate)
  (window-configuration-to-register :magit-fullscreen)
  ad-do-it
  (delete-other-windows))

;; restore previously hidden windows
(defadvice magit-mode-quit-window (around magit-restore-screen activate)
  (let ((current-mode major-mode))
    ad-do-it
    ;; we only want to jump to register when the last seen buffer
    ;; was a magit-status buffer.
    (when (eq 'magit-status-mode current-mode)
      (jump-to-register :magit-fullscreen))))

;; use emacs state in the following modes
(evil-set-initial-state 'git-commit-mode 'emacs)
(evil-set-initial-state 'magit-popup-mode 'emacs)
(evil-set-initial-state 'magit-popup-sequence-mode 'emacs)
(evil-set-initial-state 'magit-refs-mode 'emacs)
(evil-set-initial-state 'magit-revision-mode 'emacs)
