(require 'uniquify)

(column-number-mode t)
(global-font-lock-mode t)
(global-hl-line-mode -1)
(menu-bar-mode -1)
(show-paren-mode -1)
(winner-mode t)

(setq display-time-24hr-format t
      display-time-default-load-average nil
      Info-use-header-line nil
      inhibit-startup-message t
      initial-scratch-message nil
      isearch-lazy-highlight nil
      linum-format "%3d "
      pop-up-windows nil
      show-paren-style 'parenthesis
      show-paren-delay 0
      show-trailing-whitespace t
      uniquify-buffer-name-style 'forward
      uniquify-ignore-buffers-re "^\\*"
      visible-bell t
      x-select-enable-clipboard t
      xterm-mouse-mode t)

(load-theme 'ujelly t)
