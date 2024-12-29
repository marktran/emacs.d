(require 'uniquify)

(global-set-key (kbd "C-s-F") 'toggle-frame-fullscreen)
(set-face-attribute 'default nil :family "Berkeley Mono" :height 125)

(column-number-mode 1)
(global-font-lock-mode 1)
(global-hl-line-mode -1)
(menu-bar-mode -1)
(show-paren-mode -1)
(set-fringe-mode '(8 . 0))
(pixel-scroll-precision-mode 1)
(winner-mode 1)

(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'tooltip-mode) (tooltip-mode -1))

(setq-default cursor-in-non-selected-windows nil)

(setq display-time-24hr-format t
      display-time-default-load-average nil
      frame-title-format nil
      Info-use-header-line nil
      inhibit-startup-echo-area-message ""
      inhibit-startup-message t
      initial-scratch-message nil
      isearch-lazy-highlight nil
      max-mini-window-height 0
      pop-up-windows nil
      ring-bell-function 'ignore
      show-paren-style 'parenthesis
      show-paren-delay 0
      show-trailing-whitespace t
      uniquify-buffer-name-style 'forward
      uniquify-ignore-buffers-re "^\\*"
      x-select-enable-clipboard t
      xterm-mouse-mode t)

(setq-default mode-line-position
              '((-3 "%p") (size-indication-mode ("/" (-4 "%I")))
                " "
                (line-number-mode
                 ("%l" (column-number-mode ":%c")))))

;; remove $ at end of truncated lines
;; http://stackoverflow.com/questions/8370778/remove-glyph-at-end-of-truncated-lines
(set-display-table-slot standard-display-table 0 ?\ )
