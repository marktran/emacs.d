(setq dired-omit-files "^\\.?#\\|^\\.$\\|^\\.DS_Store$")

(add-hook 'dired-after-readin-hook
          (lambda ()
            (rename-buffer (concat "Dired:" (directory-file-name dired-directory)))))

;; dired+
(define-key dired-mode-map [mouse-2] 'diredp-mouse-find-file-reuse-dir-buffer)
(add-hook 'dired-mode-hook '(lambda () (dired-omit-mode 1)))

;; dired-isearch
(define-key dired-mode-map (kbd "C-s") 'dired-isearch-forward)
(define-key dired-mode-map (kbd "C-r") 'dired-isearch-backward)
(define-key dired-mode-map (kbd "ESC C-s") 'dired-isearch-forward-regexp)
(define-key dired-mode-map (kbd "ESC C-r") 'dired-isearch-backward-regexp)
