;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init.el : Mark Tran <mark@nirv.net>

;; load paths
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((lisp-dir "~/.emacs.d/")
           (default-directory lisp-dir))
      (setq load-path (cons lisp-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

(require 'init-functions)
(require 'init-keybindings)
(require 'init-libraries)
(require 'init-mail)
(require 'init-ruby)
(require 'init-scheme)
(require 'init-slime)
(require 'init-ui)
(require 'init-web)

;; mode mappings
(mapc (lambda (mapping) (add-to-list 'auto-mode-alist mapping))
      '(("\\.dtd$" . xml-mode)
        ("\\.xml$" . xml-mode)
        ("\\.yml$" . conf-mode)))

;; hooks
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)

;; set name of path/file in titlebar
(setq frame-title-format
      (list (format "%%j")
	    '(get-file-buffer "%f" (dired-directory dired-directory "%b"))))

;; copy/paste between X11 and emacs
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
;; highlight expression when closing paren
(show-paren-mode 1)
(setq show-paren-style 'parenthesis
      show-paren-delay 0)
(setq auto-save-default nil)
;; disable backup
(setq backup-inhibited t)
(setq history-length 250)
;; enable visible bell, disable audible
(setq visible-bell t)
;; automatically add trailing newline
(setq require-final-newline t)
;; tramp default transfer method
(setq tramp-default-method " ssh")
;; highlight active region
(setq transient-mark-mode t)
;; save session between restarts
(desktop-save-mode 1)
(setq desktop-save t)

;; identation
(setq tab-width 4)
(setq-default c-basic-offset 4)
(setq-default indent-tabs-mode nil)

(setq fill-column 72)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; start server
(server-start)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((Syntax . Common-Lisp)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
)

(put 'set-goal-column 'disabled nil)
