(column-number-mode t)
(global-font-lock-mode t)
(global-hl-line-mode -1)
(menu-bar-mode -1)
(show-paren-mode -1)
(winner-mode t)

(setq default-indicate-buffer-boundaries 'right
      Info-use-header-line nil
      inhibit-startup-message t
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

(load-theme 'ujelly t)
