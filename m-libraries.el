;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/m-load-libraries.el : Mark Tran <mark@nirv.net>

;; browse-kill-ring
(autoload 'browse-kill-ring "browse-kill-ring" 
  "Display kill-ring items in another buffer" t)
(browse-kill-ring-default-keybindings)

;; ido
(ido-mode t)
(setq ido-enable-flex-matching t)

(add-hook 'ido-setup-hook 
          (lambda () 
            (define-key ido-completion-map [tab] 'ido-complete)))

;; paredit
(autoload 'paredit-mode "paredit" 
  "Mode for pseudo-structurally editing Lisp code" t)

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

(provide 'm-load-libraries)
