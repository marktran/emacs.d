;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/lib.el : Mark Tran <mark@nirv.net>

;; ido
(ido-mode t)
(setq ido-enable-flex-matching t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; paredit
(autoload 'paredit-mode "paredit" 
  "Mode for pseudo-structurally editing Lisp code." t)

(dolist (hook '(emacs-lisp-mode-hook
                lisp-mode-hook
                scheme-mode-hook
                slime-repl-mode-hook))
  (add-hook hook #'(lambda nil (paredit-mode 1))))

(eval-after-load 'paredit
  '(progn
    (define-key paredit-mode-map (kbd ")")
     'paredit-close-parenthesis)
    (define-key paredit-mode-map (kbd "M-)")
     'paredit-close-parenthesis-and-newline)))

(provide 'lib)
