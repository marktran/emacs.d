;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/.ercrc.el : Mark Tran <mark@nirv.net>

(setq erc-auto-query 'buffer
      erc-button-buttonize-nicks nil
      erc-current-nick-highlight-type 'nick
      erc-header-line-format nil
      erc-hide-list '("JOIN" "PART" "NICK" "QUIT")
      erc-insert-timestamp-function 'erc-insert-timestamp-left
      erc-kill-buffer-on-part t
      erc-kill-queries-on-quit t
      erc-kill-server-buffer-on-quit t
      erc-mode-line-format "%t"
      erc-notice-prefix "* "
      erc-prompt ">"
      erc-server-auto-reconnect nil
      erc-timestamp-format "%H%M "
      erc-timestamp-only-if-changed-flag nil
      erc-track-exclude-server-buffer t
      erc-track-exclude-types '("JOIN" "MODE" "NICK" "PART" "QUIT")
      erc-track-use-faces nil)

(add-hook 'erc-mode-hook 'erc-add-scroll-to-bottom)
