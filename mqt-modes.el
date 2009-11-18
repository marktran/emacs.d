;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; load
(require 'browse-kill-ring)
(load "~/.emacs.d/vendor/nxhtml/autostart.el")
(autoload 'erc-tls "erc" nil t)
(autoload 'growl "growl" nil t)
(autoload 'smex-initialize "smex")
(autoload 'w3m "w3m-load" nil t)
(autoload 'yaml-mode "yaml-mode" nil t)

(browse-kill-ring-default-keybindings)

(eval-after-load 'flymake
  '(defun flymake-get-tex-args (file-name)
     (list "latex" (list "-file-line-error" file-name))))
(eval-after-load "init.el" '(smex-initialize))

;; settings
(setq browse-kill-ring-quit-action 'save-and-restore
      mumamo-chunk-coloring 1
      nxhtml-skip-welcome t
      nxml-degraded t
      rng-nxml-auto-validate-flag nil
      smex-prompt-string "M-x "
      smex-save-file "~/.smex.save"
      w3m-home-page
"http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_start"
      w3m-pop-up-windows nil
      w3m-show-graphic-icons-in-mode-line nil
      w3m-use-header-line nil
      w3m-use-tab nil
      w3m-use-title-buffer-name t
      w3m-use-toolbar nil
      yas/prompt-functions '(yas/ido-prompt)
      yas/use-menu 'abbreviate)

(provide 'mqt-modes)
