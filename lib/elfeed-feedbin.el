;;; elfeed-feedbin.el --- Feedbin synchronization for Elfeed -*- lexical-binding: t; -*-

;;; Commentary:

;; Use Feedbin as Elfeed's source for subscriptions, entries, unread state,
;; and starred state.  Credentials come from an auth-source entry like:
;;
;;   machine api.feedbin.com login EMAIL password PASSWORD

;;; Code:

(require 'auth-source)
(require 'cl-lib)
(require 'elfeed)
(require 'json)
(require 'seq)
(require 'url)
(require 'url-http)

(defvar url-http-end-of-headers)
(defvar url-http-response-status)

(defgroup elfeed-feedbin nil
  "Synchronize Elfeed with Feedbin."
  :group 'elfeed
  :prefix "elfeed-feedbin-")

(defcustom elfeed-feedbin-api-url "https://api.feedbin.com/v2"
  "Base URL for the Feedbin API."
  :type 'string
  :group 'elfeed-feedbin)

(defcustom elfeed-feedbin-feed-url "feedbin:"
  "Synthetic URL that triggers a Feedbin synchronization."
  :type 'string
  :group 'elfeed-feedbin)

(defcustom elfeed-feedbin-star-tag 'star
  "Elfeed tag used for Feedbin starred entries."
  :type 'symbol
  :group 'elfeed-feedbin)

(defvar elfeed-feedbin--authorization nil
  "Cached HTTP Basic authorization value for this Emacs session.")

(defvar elfeed-feedbin--enabled nil
  "Non-nil when Feedbin synchronization hooks are installed.")

(defvar elfeed-feedbin--updating nil
  "Non-nil while a Feedbin synchronization is running.")

(defvar elfeed-feedbin--applying-remote-state nil
  "Non-nil while applying Feedbin state to local entries.")

(defun elfeed-feedbin--authorization ()
  "Return a Feedbin HTTP Basic authorization value from `auth-source'."
  (or elfeed-feedbin--authorization
      (let* ((match (car (auth-source-search
                          :host "api.feedbin.com"
                          :require '(:user :secret)
                          :max 1)))
             (user (plist-get match :user))
             (secret (plist-get match :secret))
             (password (if (functionp secret) (funcall secret) secret)))
        (unless (and user password)
          (user-error
           "Add api.feedbin.com credentials to auth-source before syncing"))
        (setq elfeed-feedbin--authorization
              (concat
               "Basic "
               (base64-encode-string
                (encode-coding-string
                 (format "%s:%s" user password)
                 'utf-8)
                t))))))

(defun elfeed-feedbin-clear-credentials ()
  "Forget cached Feedbin credentials for this Emacs session."
  (interactive)
  (setq elfeed-feedbin--authorization nil)
  (auth-source-forget-all-cached))

(defun elfeed-feedbin--response-json ()
  "Parse the JSON response body in the current URL buffer."
  (goto-char (or url-http-end-of-headers (point-min)))
  (unless (eobp)
    (json-parse-buffer
     :object-type 'alist
     :array-type 'list
     :null-object nil
     :false-object nil)))

(defun elfeed-feedbin--request (method endpoint callback &optional body)
  "Request Feedbin ENDPOINT with METHOD, then call CALLBACK.
CALLBACK receives DATA and ERROR.  BODY is encoded as JSON when non-nil."
  (condition-case error
      (let ((url-request-method method)
            (url-request-extra-headers
             `(("Authorization" . ,(elfeed-feedbin--authorization))
               ("Accept" . "application/json")
               ("Content-Type" . "application/json; charset=utf-8")))
            (url-request-data
             (when body
               (encode-coding-string (json-encode body) 'utf-8))))
        (url-retrieve
         (concat elfeed-feedbin-api-url endpoint)
         (lambda (status)
           (let ((buffer (current-buffer)))
             (unwind-protect
                 (cond
                  ((plist-get status :error)
                   (funcall callback nil
                            (format "Network error: %S"
                                    (plist-get status :error))))
                  ((or (not (numberp url-http-response-status))
                       (>= url-http-response-status 400))
                   (funcall callback nil
                            (if (eq url-http-response-status 401)
                                "Feedbin rejected the configured credentials"
                              (format "Feedbin returned HTTP %s"
                                      url-http-response-status))))
                  (t
                   (let (data parse-error)
                     (condition-case err
                         (setq data (elfeed-feedbin--response-json))
                       (error (setq parse-error err)))
                     (if parse-error
                         (funcall callback nil
                                  (format "Invalid Feedbin response: %s"
                                          (error-message-string parse-error)))
                       (funcall callback data nil)))))
               (when (buffer-live-p buffer)
                 (kill-buffer buffer)))))
         nil t t))
    (error
     (funcall callback nil (error-message-string error)))))

(defun elfeed-feedbin--chunk (items size)
  "Split ITEMS into lists containing at most SIZE elements."
  (let (chunks)
    (while items
      (push (seq-take items size) chunks)
      (setq items (seq-drop items size)))
    (nreverse chunks)))

(defun elfeed-feedbin--fetch-entry-chunks (chunks entries callback)
  "Fetch Feedbin entry CHUNKS, accumulating ENTRIES for CALLBACK."
  (if-let ((chunk (car chunks)))
      (elfeed-feedbin--request
       "GET"
       (format "/entries.json?ids=%s"
               (mapconcat #'number-to-string chunk ","))
       (lambda (data error)
         (if error
             (funcall callback nil error)
           (elfeed-feedbin--fetch-entry-chunks
            (cdr chunks) (nconc entries data) callback))))
    (funcall callback entries nil)))

(defun elfeed-feedbin--id-table (ids)
  "Return an equality hash table containing IDS."
  (let ((table (make-hash-table :test #'eql)))
    (dolist (id ids table)
      (puthash id t table))))

(defun elfeed-feedbin--subscription-table (subscriptions)
  "Create feeds and return a Feedbin feed ID table for SUBSCRIPTIONS."
  (let ((table (make-hash-table :test #'eql)))
    (dolist (subscription subscriptions table)
      (let* ((feed-id (alist-get 'feed_id subscription))
             (feed-url (alist-get 'feed_url subscription))
             (feed (elfeed-db-get-feed feed-url)))
        (puthash feed-id subscription table)
        (setf (elfeed-feed-url feed) feed-url
              (elfeed-feed-title feed) (alist-get 'title subscription)
              (elfeed-meta feed :feedbin-feed-id) feed-id
              (elfeed-meta feed :feedbin-subscription-id)
              (alist-get 'id subscription)
              (elfeed-meta feed :site-url)
              (alist-get 'site_url subscription))))))

(defun elfeed-feedbin--entry-date (item)
  "Return the publication time for Feedbin entry ITEM."
  (condition-case nil
      (float-time
       (date-to-time
        (or (alist-get 'published item)
            (alist-get 'created_at item))))
    (error (float-time))))

(defun elfeed-feedbin--make-entry (item subscriptions unread starred)
  "Convert Feedbin ITEM to an Elfeed entry.
SUBSCRIPTIONS maps Feedbin feed IDs.  UNREAD and STARRED are ID tables."
  (let* ((id (alist-get 'id item))
         (feed-id (alist-get 'feed_id item))
         (subscription (gethash feed-id subscriptions))
         (feed-url (or (alist-get 'feed_url subscription)
                       (format "feedbin:feed:%s" feed-id)))
         (html (alist-get 'content item))
         (summary (alist-get 'summary item))
         (author (alist-get 'author item))
         tags)
    (when (gethash id unread)
      (push 'unread tags))
    (when (gethash id starred)
      (push elfeed-feedbin-star-tag tags))
    (elfeed-entry--create
     :id (cons "feedbin" (number-to-string id))
     :feed-id feed-url
     :title (elfeed-cleanup (alist-get 'title item))
     :link (elfeed-cleanup (alist-get 'url item))
     :date (elfeed-feedbin--entry-date item)
     :content (or html summary)
     :content-type (and html 'html)
     :tags (elfeed-normalize-tags tags)
     :meta `( :feedbin-id ,id
              ,@(when author
                  (list :authors (list (list :name author))))))))

(defun elfeed-feedbin--feedbin-entry-p (entry)
  "Return non-nil when ENTRY came from Feedbin."
  (integerp (elfeed-meta entry :feedbin-id)))

(defun elfeed-feedbin--migrate-local-database ()
  "Remove pre-Feedbin entries once to avoid duplicate articles."
  (unless (plist-get elfeed-db :feedbin-migration-version)
    (let (local-entries)
      (maphash
       (lambda (_id entry)
         (unless (elfeed-feedbin--feedbin-entry-p entry)
           (push entry local-entries)))
       elfeed-db-entries)
      (elfeed-db-delete local-entries)
      (setq elfeed-db
            (plist-put elfeed-db :feedbin-migration-version 1)))))

(defun elfeed-feedbin--apply-tag-state (entries tag present-p)
  "Ensure ENTRIES have TAG exactly when PRESENT-P returns non-nil."
  (let (add remove)
    (dolist (entry entries)
      (if (funcall present-p entry)
          (unless (memq tag (elfeed-entry-tags entry))
            (push entry add))
        (when (memq tag (elfeed-entry-tags entry))
          (push entry remove))))
    (when add
      (elfeed-tag add tag))
    (when remove
      (elfeed-untag remove tag))))

(defun elfeed-feedbin--apply-remote-state (unread starred)
  "Apply Feedbin UNREAD and STARRED ID tables to all local entries."
  (let (entries)
    (maphash
     (lambda (_id entry)
       (when (elfeed-feedbin--feedbin-entry-p entry)
         (push entry entries)))
     elfeed-db-entries)
    (let ((elfeed-feedbin--applying-remote-state t))
      (elfeed-feedbin--apply-tag-state
       entries 'unread
       (lambda (entry)
         (gethash (elfeed-meta entry :feedbin-id) unread)))
      (elfeed-feedbin--apply-tag-state
       entries elfeed-feedbin-star-tag
       (lambda (entry)
         (gethash (elfeed-meta entry :feedbin-id) starred))))))

(defun elfeed-feedbin--finish-sync (callback error &optional count)
  "Finish a sync by invoking Elfeed CALLBACK with ERROR or entry COUNT."
  (setq elfeed-feedbin--updating nil)
  (if error
      (progn
        (message "Feedbin sync failed: %s" error)
        (funcall callback :error))
    (elfeed-db-save)
    (elfeed-search-update :force)
    (message "Feedbin sync complete: %d entries" (or count 0))
    (funcall callback :success)))

(defun elfeed-feedbin--import (subscriptions unread-ids starred-ids callback)
  "Import Feedbin state and entries, then invoke Elfeed CALLBACK."
  (let* ((subscription-table
          (elfeed-feedbin--subscription-table subscriptions))
         (unread (elfeed-feedbin--id-table unread-ids))
         (starred (elfeed-feedbin--id-table starred-ids))
         (ids (delete-dups (append unread-ids starred-ids))))
    (elfeed-feedbin--fetch-entry-chunks
     (elfeed-feedbin--chunk ids 100) nil
     (lambda (items error)
       (if error
           (elfeed-feedbin--finish-sync callback error)
         (elfeed-feedbin--migrate-local-database)
         (elfeed-db-add
          (mapcar
           (lambda (item)
             (elfeed-feedbin--make-entry
              item subscription-table unread starred))
           items))
         (elfeed-feedbin--apply-remote-state unread starred)
         (elfeed-feedbin--finish-sync callback nil (length items)))))))

(defun elfeed-feedbin--sync (callback)
  "Synchronize Feedbin and invoke the Elfeed fetch CALLBACK."
  (if elfeed-feedbin--updating
      (progn
        (message "Feedbin sync is already running")
        (funcall callback :error))
    (setq elfeed-feedbin--updating t)
    (elfeed-feedbin--request
     "GET" "/subscriptions.json"
     (lambda (subscriptions error)
       (if error
           (elfeed-feedbin--finish-sync callback error)
         (elfeed-feedbin--request
          "GET" "/unread_entries.json"
          (lambda (unread-ids error)
            (if error
                (elfeed-feedbin--finish-sync callback error)
              (elfeed-feedbin--request
               "GET" "/starred_entries.json"
               (lambda (starred-ids error)
                 (if error
                     (elfeed-feedbin--finish-sync callback error)
                   (elfeed-feedbin--import
                    subscriptions unread-ids starred-ids callback))))))))))))

(defun elfeed-feedbin-fetch (url callback)
  "Handle Elfeed URL with CALLBACK when URL is the Feedbin source."
  (when (equal url elfeed-feedbin-feed-url)
    (elfeed-feedbin--sync callback)
    t))

(defun elfeed-feedbin--entry-ids (entries)
  "Return Feedbin IDs for ENTRIES."
  (delq nil
        (mapcar
         (lambda (entry)
           (elfeed-meta entry :feedbin-id))
         entries)))

(defun elfeed-feedbin--push-state (endpoint key ids present)
  "Set Feedbin state ENDPOINT for IDS under JSON KEY to PRESENT."
  (dolist (chunk (elfeed-feedbin--chunk ids 1000))
    (elfeed-feedbin--request
     (if present "POST" "DELETE") endpoint
     (lambda (_data error)
       (when error
         (message "Feedbin state update failed: %s" error)))
     `((,key . ,chunk)))))

(defun elfeed-feedbin--tags-changed (entries tags present)
  "Push changed TAGS for ENTRIES to Feedbin as PRESENT."
  (unless elfeed-feedbin--applying-remote-state
    (when-let ((ids (elfeed-feedbin--entry-ids entries)))
      (when (memq 'unread tags)
        (elfeed-feedbin--push-state
         "/unread_entries.json" 'unread_entries ids present))
      (when (memq elfeed-feedbin-star-tag tags)
        (elfeed-feedbin--push-state
         "/starred_entries.json" 'starred_entries ids present)))))

(defun elfeed-feedbin--tagged (entries tags)
  "Push added TAGS for ENTRIES to Feedbin."
  (elfeed-feedbin--tags-changed entries tags t))

(defun elfeed-feedbin--untagged (entries tags)
  "Push removed TAGS for ENTRIES to Feedbin."
  (elfeed-feedbin--tags-changed entries tags nil))

;;;###autoload
(defun elfeed-feedbin-enable ()
  "Enable Feedbin fetching and read/star state synchronization."
  (interactive)
  (unless elfeed-feedbin--enabled
    (add-hook 'elfeed-fetch-functions #'elfeed-feedbin-fetch)
    (add-hook 'elfeed-tag-hook #'elfeed-feedbin--tagged)
    (add-hook 'elfeed-untag-hook #'elfeed-feedbin--untagged)
    (setq elfeed-feedbin--enabled t)))

;;;###autoload
(defun elfeed-feedbin-disable ()
  "Disable Feedbin fetching and state synchronization."
  (interactive)
  (remove-hook 'elfeed-fetch-functions #'elfeed-feedbin-fetch)
  (remove-hook 'elfeed-tag-hook #'elfeed-feedbin--tagged)
  (remove-hook 'elfeed-untag-hook #'elfeed-feedbin--untagged)
  (setq elfeed-feedbin--enabled nil))

(provide 'elfeed-feedbin)
;;; elfeed-feedbin.el ends here
