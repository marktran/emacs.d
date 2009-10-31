;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-ui.el : Mark Tran <mark@nirv.net>

;; modes
(column-number-mode 1)
(fringe-mode '(0 . right-only))
(global-font-lock-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)
(winner-mode 1)

;; settings
(setq default-indicate-buffer-boundaries 'right
      Info-use-header-line nil
      inhibit-startup-message t
      interprogram-paste-function 'x-cut-buffer-or-selection-value
      linum-format "%3d "
      pop-up-windows nil
      show-paren-style 'parenthesis
      show-paren-delay 0
      show-trailing-whitespace t
      visible-bell t
      x-select-enable-clipboard t)

(setq-default cursor-in-non-selected-windows nil
              left-margin-width 1)

(put 'set-goal-column 'disabled nil)

;; bars
(when window-system
  (blink-cursor-mode -1)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)

  (setq frame-title-format
        (list (format "%%j")
              '(get-file-buffer "%f" (dired-directory dired-directory "%b")))))

;; fringe, margins
(define-fringe-bitmap 'bottom-right-angle [0] nil)
(define-fringe-bitmap 'right-arrow [0] nil)
(define-fringe-bitmap 'right-bracket [0] nil)
(define-fringe-bitmap 'top-left-angle [0] nil)
(define-fringe-bitmap 'top-right-angle [0] nil)
(set-window-margins nil 1 0)

;; transparency
(add-to-list 'default-frame-alist '(alpha . 98))

;; color theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-choco)

(provide 'mqt-ui)
