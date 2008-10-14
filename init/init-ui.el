;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-ui.el : Mark Tran <mark@nirv.net>

;; winner mode
(when (fboundp 'winner-mode)
  (winner-mode 1))

;; enable syntax highlighting
(global-font-lock-mode 1)

;; highlight expression when closing paren
(show-paren-mode 1)
(setq show-paren-style 'parenthesis
      show-paren-delay 0)

;; highlight active region
(setq transient-mark-mode t)

;; set name of path/file in titlebar
(setq frame-title-format
      (list (format "%%j")
	    '(get-file-buffer "%f" (dired-directory dired-directory "%b"))))

;; enable visible bell, disable audible
(setq visible-bell t)
;; font
(set-default-font "-xos4-terminus-medium-*-normal-*-12-*-*-*-*-*-iso10646-1")
;; remove splashscreen
(setq inhibit-startup-message t)
;; disable menubar
(menu-bar-mode -1)
;; add margin to buffers/windows
(setq-default left-margin-width 1)
(set-window-margins nil 1 0)
;; hide hollow cursor on inactive windows
(setq-default cursor-in-non-selected-windows nil)

;; show column number on mode line
(column-number-mode 1)
;; replace yes-or-no-p with y-or-n-p
(fset 'yes-or-no-p 'y-or-n-p)

;; bar/fringe
(fringe-mode '(0 . right-only))
(define-fringe-bitmap 'top-left-angle [0] nil)
(define-fringe-bitmap 'top-right-angle [0] nil)
(define-fringe-bitmap 'bottom-right-angle [0] nil)
(blink-cursor-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq-default scroll-bar-width 10)             
(tool-bar-mode -1)
(tooltip-mode -1)

(setq default-indicate-buffer-boundaries 'right)
 
;; info-buffer
;; disable info header line
(setq Info-use-header-line nil)

(put 'set-goal-column 'disabled nil)

;; initialize and apply color theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-outback)

(provide 'init-ui)
