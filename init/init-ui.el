;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-ui.el : Mark Tran <mark@nirv.net>

;; color theme
(require 'color-theme)

;; enable syntax highlighting
(global-font-lock-mode 1)

;; initialize and apply color theme
(color-theme-initialize)
(color-theme-outback)

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

;; ui customization
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

(provide 'init-ui)
