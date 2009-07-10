;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-modes.el : Mark Tran <mark@nirv.net>

;; cc
(c-set-offset 'case-label '+)

;; ediff
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
(setq ediff-split-window-function 'split-window-horizontally)

(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))

;; erc
(setq erc-user-full-name "Mark T."
      erc-email-userid "tran"
      erc-nick '("mqt" "qvt")
      erc-server "irc.freenode.net"
      erc-port 6667
      erc-prompt-for-password nil)

;; eshell
(setq eshell-ls-initial-args "-F"
      eshell-ls-use-colors nil)

(setq eshell-prompt-function
  (lambda ()
    (concat "(" (eshell/pwd) ")"
      (if (= (user-uid) 0) " # " " % "))))

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

(provide 'init-modes)
