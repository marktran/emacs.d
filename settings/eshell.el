(setq eshell-aliases-file "~/.emacs.d/eshell/alias"
      eshell-banner-message ""
      eshell-last-dir-ring-size 10
      eshell-list-files-after-cd t)

(add-hook 'eshell-mode-hook
          (lambda ()
            (dolist (command '("htop"
                               "ssh"))
              (add-to-list 'eshell-visual-commands command))

            (local-set-key (kbd "C-w C-k") 'windmove-up)
            (local-set-key (kbd "C-w C-l") 'windmove-right)
            (local-set-key (kbd "C-w C-j") 'windmove-down)
            (local-set-key (kbd "C-w C-h") 'windmove-left)

            (local-set-key (kbd "C-w k") 'windmove-up)
            (local-set-key (kbd "C-w l") 'windmove-right)
            (local-set-key (kbd "C-w j") 'windmove-down)
            (local-set-key (kbd "C-w h") 'windmove-left)))

