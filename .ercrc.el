;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/.ercrc.el : Mark Tran <mark@nirv.net>

(setq erc-auto-query 'buffer
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
      erc-track-priority-faces-only '("#clojure"
                                      "#cloudkick-updates"
                                      "#django"
                                      "#emacs"
                                      "##javascript"
                                      "#lisp"
                                      "#prgmr"
                                      "#python"
                                      "#scc-pre"
                                      "#startups")
      erc-whowas-on-nosuchnick t)

(setq erc-keywords
      (mapcar (lambda (x) (concat "^\\[PRE\\] \\[ TV \\] \\[ " x))
              '("Californication"
                "Curb.Your.Enthusiasm"
                "Dexter"
                "Doctor.Who"
                "Entourage"
                "Heroes"
                "How.I.Met.Your.Mother"
                "Its.Always.Sunny.In.Philadelphia"
                "Jeopardy"
                "Mad.Men"
                "Man.v.Food"
                "Monk"
                "Sons.of.Anarchy"
                "The.Big.Bang.Theory"
                "The.IT.Crowd"
                "The.Office"
                "Top.Gear"
                "True.Blood")))

(add-hook 'erc-mode-hook 'erc-add-scroll-to-bottom)
(add-hook 'erc-mode-hook 'turn-on-visual-line-mode)

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
