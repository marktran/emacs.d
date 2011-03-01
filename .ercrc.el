;;; .emacs.d/.ercrc.el : Mark Tran <mark@nirv.net>

(setq erc-auto-query 'bury
      erc-button-buttonize-nicks nil
      erc-current-nick-highlight-type 'nick
      erc-default-server "lambda.nirv.net"
      erc-default-port 65535
      erc-disable-ctcp-replies t
      erc-header-line-format nil
      erc-hide-list '("JOIN", "PART", "QUIT")
      erc-insert-timestamp-function 'erc-insert-timestamp-left
      erc-keyword-highlight-type 'all
      erc-kill-buffer-on-part t
      erc-kill-queries-on-quit t
      erc-kill-server-buffer-on-quit t
      erc-mode-line-format "%t"
      erc-notice-prefix "* "
      erc-prompt ">"
      erc-prompt-for-password nil
      erc-query-display 'buffer
      erc-server-auto-reconnect nil
      erc-timestamp-format "%H:%M "
      erc-timestamp-only-if-changed-flag nil
      erc-track-exclude-server-buffer t
      erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                "324" "329" "332" "333" "353" "477")
      erc-track-faces-priority-list '(erc-current-nick-face
                                      erc-error-face
                                      erc-keyword-face
                                      erc-pal-face)
      erc-track-priority-faces-only '("#scc-pre")
      erc-whowas-on-nosuchnick t)

(add-hook 'erc-mode-hook 'erc-add-scroll-to-bottom)
(add-hook 'erc-mode-hook 'turn-on-visual-line-mode)

;; http://www.emacswiki.org/emacs/ErcChannelTracking#toc5
(defadvice erc-track-find-face (around erc-track-find-face-promote-query activate)
  (if (erc-query-buffer-p) 
      (setq ad-return-value (intern "fg:erc-color-face4"))
    ad-do-it))

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
