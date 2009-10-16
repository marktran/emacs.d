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

;; growl notifcation for mentions and keywords
(defun growl-chat (title message)
  (interactive "sTitle: \nsMessage: ")
  (shell-command-to-string
   (format "/opt/local/bin/growlnotify --appIcon 'Emacs' -t $'%s' -m $'%s'" 
           (replace-regexp-in-string "'" "\\\\'" title)
           (replace-regexp-in-string "'" "\\\\'" message))))

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
                  (growl-chat
                   (format "ERC")
                   (format "<%s> %s" nick message)))
                 ((eq match-type 'keyword)
                  (growl-chat 
                   (format "ERC")
                   (format "<%s> %s" nick message))))))))
