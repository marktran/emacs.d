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
      erc-timestamp-format "%H:%M "
      erc-timestamp-only-if-changed-flag nil
      erc-track-exclude-server-buffer t
      erc-track-exclude-types '("JOIN" "MODE" "NICK" "PART" "QUIT")
      erc-track-use-faces nil)

(add-hook 'erc-mode-hook 'erc-add-scroll-to-bottom)

;; growl notifcations for mentions and keywords
(when (eq system-type 'darwin)
  (add-hook 'erc-text-matched-hook
            (lambda (match-type nickuserhost message)
              (when (and
                     (boundp 'nick)
                     (not (string= nick "ChanServ"))
                     (not (string= nick "services."))
                     (not (string= nick (erc-current-nick))))
                (cond
                 ((eq match-type 'current-nick)
                  (growl
                   (format "ERC")
                   (format "<%s> %s" nick message)))
                 ((eq match-type 'keyword)
                  (growl
                   (format "ERC")
                   (format "<%s> %s" nick message))))))))
