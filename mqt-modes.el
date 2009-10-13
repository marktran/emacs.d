;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-modes.el : Mark Tran <mark@nirv.net>

;; mode mappings
(mapc (lambda (mapping) (add-to-list 'auto-mode-alist mapping))
      '(("\\.dtd$" . xml-mode)
        ("\\.lua$" . lua-mode)
        ("\\.xml$" . xml-mode)
        ("\\.yml$" . conf-mode)))

;; cc
(c-set-offset 'case-label '+)

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))

;; eshell
(setq eshell-ls-initial-args "-F"
      eshell-ls-use-colors nil)

;; hl-line
(global-hl-line-mode 1)
(set-face-background 'hl-line "#2b1811")

;; ido
(ido-mode t)
(setq ido-enable-flex-matching t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; makefile
(add-hook 'makefile-mode-hook 
  (lambda()
    (setq show-trailing-whitespace t)))

;; org
(setq org-hide-leading-stars t
      org-startup-folded nil)

;; text-mode
(add-hook 'text-mode-hook 'turn-on-auto-fill)

(provide 'mqt-modes)
