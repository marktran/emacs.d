;;; .emacs.d/mqt-ui.el : Mark Tran <mark@nirv.net>

;; modes
(column-number-mode 1)
(global-font-lock-mode 1)
(global-hl-line-mode -1)
(menu-bar-mode -1)
(show-paren-mode -1)
(winner-mode 1)

;; settings
(setq default-indicate-buffer-boundaries 'right
      Info-use-header-line nil
      inhibit-startup-message t
      linum-format "%3d "
      pop-up-windows nil
      ring-bell-function (lambda nil (message ""))
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

;; transparency
(add-to-list 'default-frame-alist '(alpha . 99))

(load-theme 'ujelly t)

(provide 'mqt-ui)
