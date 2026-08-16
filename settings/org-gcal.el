;;; org-gcal.el --- Sync Google Calendar into Org

;; Bidirectional sync between mark.tran@gmail.com's Google Calendar
;; and ~/Dropbox/org/now/gcal.org via the Calendar API. Google
;; Calendar is the source of truth: `org-gcal-sync' (or
;; `org-gcal-fetch') mirrors events into the file, and edits to
;; existing events are pushed back with `org-gcal-post-at-point'
;; (which also turns a fresh headline into a new event).
;;
;; The OAuth client comes from a personal Google Cloud project with
;; the Calendar API enabled and a Desktop-type OAuth client ID, with
;; the consent screen published to production (in "Testing" status
;; Google expires refresh tokens after 7 days). Credentials live in
;; ~/.authinfo as:
;;
;;   machine org-gcal login <client-id> password <client-secret>
;;
;; The first sync opens a browser for the OAuth grant. Tokens are
;; kept in a plstore encrypted to a dedicated, passphrase-less GPG
;; key (same trust model as plaintext ~/.authinfo; symmetric plstore
;; encryption fails with (epg-error "Encrypt failed") when driven
;; from org-gcal's timers). To recreate the key on a new machine:
;;
;;   gpg --batch --passphrase '' --quick-generate-key \
;;       'Mark Tran (plstore) <mark.tran@gmail.com>' default default never
;;
;; then update `plstore-encrypt-to' below with the new fingerprint.

(use-package org-gcal
  :ensure t

  :commands (org-gcal-sync
             org-gcal-fetch
             org-gcal-sync-buffer
             org-gcal-fetch-buffer
             org-gcal-post-at-point
             org-gcal-delete-at-point)

  :custom
  (org-gcal-fetch-file-alist
   '(("mark.tran@gmail.com" . "~/Dropbox/org/now/gcal.org")))
  ;; org-generic-id (bundled with org-gcal) defaults its cache to
  ;; ~/.emacs.d/.org-generic-id-locations; keep it under var/.
  (org-generic-id-locations-file
   (no-littering-expand-var-file-name "org-generic-id-locations.el"))
  ;; Encrypt the token store to the dedicated GPG key; public-key
  ;; encryption needs no passphrase prompts, which timer-driven
  ;; syncs can't service.
  (plstore-encrypt-to '("6CCFFAECC5B09095B321B2299663F2034073E128"))
  ;; Prompt for passphrases in the minibuffer; an external pinentry
  ;; can hang mid-sync (kidd/org-gcal.el#267).
  (epg-pinentry-mode 'loopback)

  :init
  ;; OAuth tokens land in an encrypted plstore; keep it under
  ;; no-littering's var/ instead of ~/.emacs.d/oauth2-auto.plist.
  (setq oauth2-auto-plstore (no-littering-expand-var-file-name "oauth2-auto.plist"))

  ;; org-gcal hands the client credentials to oauth2-auto when the
  ;; package loads, so they must be set beforehand.
  (defun m/org-gcal-save-fetch-files (&rest _)
    "Save modified buffers visiting `org-gcal-fetch-file-alist' files."
    (dolist (file (mapcar #'cdr org-gcal-fetch-file-alist))
      (when-let* ((buf (get-file-buffer file)))
        (with-current-buffer buf
          (when (buffer-modified-p)
            (save-buffer))))))

  (let* ((match (car (auth-source-search
                      :host "org-gcal"
                      :require '(:user :secret)
                      :max 1)))
         (secret (plist-get match :secret)))
    (if match
        (setq org-gcal-client-id (plist-get match :user)
              org-gcal-client-secret (if (functionp secret) (funcall secret) secret))
      (message "org-gcal: no `machine org-gcal' entry in ~/.authinfo; syncing won't work")))

  :config
  ;; org-gcal writes fetched events into the fetch-file buffer but
  ;; never saves it, so nothing reaches disk (or Dropbox) until the
  ;; buffer is saved by hand. `org-gcal--sync-unlock' runs when a
  ;; sync settles, on both the success and failure paths.
  (advice-add 'org-gcal--sync-unlock :after #'m/org-gcal-save-fetch-files))
