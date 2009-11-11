;;; -*- Mode: Emacs-Lisp; -*-

;;; .gnus.el : Mark Tran <mark@nirv.net>

;; encrypted authinfo file with gnupg
;; http://www.emacswiki.org/emacs/GnusEncryptedAuthInfo
(require 'epa-file)
(setq epa-file-cache-passphrase-for-symmetric-encryption t)

;; settings
(setq user-full-name "Mark Tran"
      user-mail-address "mark@nirv.net")

(setq gnus-select-method
      '(nntp "news.csh.rit.edu"
             (nntp-open-connection-function nntp-open-ssl-stream)
             (nntp-address "news.csh.rit.edu")
             (nntp-port-number 563))
      nntp-authinfo-file "~/.netrc.gpg")

(setq gnus-secondary-select-methods
      '((nntp "news.gmane.org"
              (nntp-address "news.gmane.org")
              (nntp-port-number 119))))

(setq gnus-inhibit-startup-message t
      gnus-interactive-exit nil
      gnus-mode-line-image-cache nil
      gnus-novice-user nil
      gnus-summary-display-arrow nil
      gnus-summary-dummy-line-format ""
      gnus-summary-line-format "%U %d %-20,20n %B%s\n"
      gnus-summary-mode-line-format "%g [%A / %z] %Z"
      gnus-treat-display-smileys nil
      gnus-use-cache 'passive
      gnus-use-full-window nil
      gnus-visible-headers "^From:\\|^Subject:\\|^Date:\\|
^Followup-To:\\|^Reply-To:\\|^Summary:\\|^Keywords:\\|^To:\\|^[BGF]?Cc:\\|
^Posted-To:\\|^Mail-Copies-To:\\|^Mail-Followup-To:\\|^Apparently-To:\\|
^Gnus-Warning:\\|^Resent-From:\\|^X-Sent:"
      message-from-style 'angles)

;; scoring
(setq gnus-use-adaptive-scoring t
      gnus-default-adaptive-score-alist
      '((gnus-unread-mark)
        (gnus-ticked-mark (subject 5)) 
        (gnus-read-mark (subject 1)) 
        (gnus-catchup-mark (subject -1)) 
        (gnus-killed-mark (subject -5))))

(add-hook 'message-sent-hook 'gnus-score-followup-article)

(gnus-compile)
