;;; notmuch.el --- Gmail mail with Notmuch on Linux -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs frontend settings for the local Notmuch mail index. System
;; installation, Gmail authorization, background synchronization, and
;; troubleshooting are documented in the parent dotfiles repository at
;; docs/EMACS.md.
;;
;; `SPC m' opens the Notmuch home screen in `Dashboard'. It shares the main
;; Emacs dashboard's centered title and section styling. `/'
;; moves to its search box and enters Insert state. Inbox, Trash, Spam, Sent,
;; Starred, and Drafts searches use matching buffer names; other queries use
;; `Search: query', and opened threads use `View'.
;; Mailbox and ad hoc search results show From, Subject, and Date without thread
;; counts. Inbox, Trash, and Spam are grouped by month and year. Today's
;; messages show their time; older messages use `Month Day'.
;; Message summary lines display the sender as `From:' and comma-separated tags
;; as `Labels:'. `U' toggles read/unread. `g i', `g #', `g !', `g t', `g s',
;; and `g d' open Inbox, Trash, Spam, Sent, Starred, and Drafts, replacing the
;; current Notmuch buffer. `G' invokes `notmuch-sync' and refreshes the view;
;; normal background synchronization does not require Emacs to be running.
;; Search results are newest-first.
;;
;; Plain text is preferred when a message provides multiple alternatives and
;; inherits the normal Emacs font, Berkeley Mono. Long HTTP links retain their
;; full targets but display a compact path. `H' toggles the current message's
;; HTML alternative inline when its richer rendering is needed.
;;
;; Composing and replying use Message mode and the `notmuch-sendmail' helper.
;; Gmail creates the Sent copy, so this configuration deliberately disables
;; Notmuch's local Fcc to avoid duplicates.
;;
;; Gmail labels appear as Notmuch tags. Archiving removes `inbox'; `#' follows
;; Gmail's shortcut and moves selected threads to `trash'. The tag menu also
;; uses `trash' instead of Notmuch's local-only `deleted' tag so deletions
;; propagate to Gmail during synchronization. The dashboard, search, and
;; message views all display `Notmuch' as their major-mode name.

;;; Code:

(declare-function dashboard-center-text "dashboard-widgets" (start end))
(declare-function dashboard-insert-banner-title "dashboard-widgets" ())
(declare-function dashboard-insert-heading "dashboard-widgets"
                  (heading &optional shortcut icon))
(declare-function evil-insert-state "evil-states" ())
(declare-function evil-local-set-key "evil-core" (state key def))
(declare-function notmuch-apply-face "notmuch-lib"
                  (object face &optional below start end))
(declare-function notmuch-interactive-region "notmuch-lib" ())
(declare-function notmuch-hello-nice-number "notmuch-hello" (n))
(declare-function notmuch-hello-query-counts "notmuch-hello"
                  (query-list &rest options))
(declare-function notmuch-hello-search "notmuch-hello" (widget &rest event))
(declare-function notmuch-hello-widget-search "notmuch-hello"
                  (widget &rest ignore))
(declare-function notmuch-sanitize "notmuch-lib" (str))
(declare-function notmuch-search "notmuch"
                  (&optional query oldest-first hide-excluded target-thread
                             target-line no-display))
(declare-function notmuch-search-get-tags-region "notmuch" (beg end))
(declare-function notmuch-search-next-thread "notmuch" ())
(declare-function notmuch-search-tag "notmuch"
                  (tag-changes &optional beg end only-matched))
(declare-function notmuch-show-clean-address "notmuch-show" (address))
(declare-function notmuch-show-get-prop "notmuch-show" (prop &optional props))
(declare-function notmuch-show-get-tags "notmuch-show" ())
(declare-function notmuch-show-mapc "notmuch-show" (function))
(declare-function notmuch-show-message-extent "notmuch-show" ())
(declare-function notmuch-show-next-thread "notmuch-show"
                  (&optional show previous))
(declare-function notmuch-show-spaces-n "notmuch-show" (n))
(declare-function notmuch-show-tag-all "notmuch-show" (tag-changes))
(declare-function notmuch-show-toggle-part-invisibility "notmuch-show"
                  (&optional button))
(declare-function notmuch-tag-format-tag "notmuch-tag"
                  (tags orig-tags tag))
(declare-function widget-field-buffer "wid-edit" (widget))
(declare-function widget-field-start "wid-edit" (widget))

(defvar dashboard-banner-logo-title)
(defvar goto-address-mail-face)
(defvar goto-address-url-regexp)
(defvar notmuch-saved-search-sort-function)
(defvar notmuch-saved-searches)
(defvar notmuch-search-hide-excluded)
(defvar notmuch-search-oldest-first)

(use-package notmuch
  :ensure t
  :after dashboard
  :commands notmuch

  :preface
  (defun m/notmuch-search-buffer-title (orig query &optional type)
    "Give exact mailbox QUERY values concise names.
Call ORIG with QUERY and TYPE for all other searches."
    (cond
     ((equal query "tag:inbox") "Inbox")
     ((equal query "tag:trash") "Trash")
     ((equal query "tag:spam") "Spam")
     ((equal query "tag:sent") "Sent")
     ((equal query "tag:flagged") "Starred")
     ((equal query "tag:draft") "Drafts")
     (t (funcall orig query type))))

  (defconst m/notmuch-mailbox-buffer-names
    '("Inbox" "Trash" "Spam" "Sent" "Starred" "Drafts")
    "Notmuch search buffers that use the mailbox layout.")

  (defconst m/notmuch-grouped-mailbox-buffer-names
    '("Inbox" "Trash" "Spam")
    "Notmuch mailbox buffers that group results by month and year.")

  (defvar-local m/notmuch-search-group-by-month nil
    "Whether the current search groups results by month.")

  (defvar-local m/notmuch-search-last-month nil
    "Month heading most recently added to the current search.")

  (defun m/notmuch-search-column (text width face &optional right-align)
    "Format TEXT in a WIDTH-column field using FACE.
Right-align the field when RIGHT-ALIGN is non-nil."
    (let* ((truncated (> (string-width text) width))
           (visible (if truncated
                        (concat (truncate-string-to-width
                                 text (max 0 (1- width)))
                                "…")
                      text))
           (padding (make-string (max 0 (- width (string-width visible))) ?\s))
           (field (if right-align
                      (concat padding visible)
                    (concat visible padding))))
      (propertize field 'face face
                  'help-echo (and truncated text))))

  (defun m/notmuch-search-date (timestamp)
    "Format TIMESTAMP as a time today or as `Month Day' otherwise."
    (let ((time (seconds-to-time timestamp)))
      (if (equal (format-time-string "%Y-%m-%d" time)
                 (format-time-string "%Y-%m-%d"))
          (format-time-string "%H:%M" time)
        (format "%s %d"
                (format-time-string "%B" time)
                (string-to-number (format-time-string "%d" time))))))

  (defun m/notmuch-search-format-mailbox-result (_format result)
    "Format a mailbox RESULT as From, Subject, and Date."
    (let* ((window (get-buffer-window (current-buffer) t))
           (width (max 60 (1- (if window
                                  (window-body-width window)
                                100))))
           (date-width 12)
           (from-width (min 28 (max 20 (/ width 4))))
           (subject-width (max 20 (- width from-width date-width 4)))
           (from (replace-regexp-in-string
                  "|" ", " (notmuch-sanitize (plist-get result :authors))
                  t t))
           (subject (notmuch-sanitize (plist-get result :subject)))
           (date (m/notmuch-search-date (plist-get result :timestamp))))
      (concat
       (m/notmuch-search-column
        from from-width 'notmuch-search-matching-authors)
       "  "
       (m/notmuch-search-column
        subject subject-width 'notmuch-search-subject)
       "  "
       (m/notmuch-search-column
        date date-width 'notmuch-search-date t))))

  (defun m/notmuch-mailbox-layout ()
    "Use the three-column layout in mailbox and search buffers."
    (when (or (member (buffer-name) m/notmuch-mailbox-buffer-names)
              (string-prefix-p "Search: " (buffer-name)))
      (setq-local m/notmuch-search-group-by-month
                  (not (null (member
                              (buffer-name)
                              m/notmuch-grouped-mailbox-buffer-names))))
      (setq-local m/notmuch-search-last-month nil)
      (setq-local notmuch-search-result-format
                  '((m/notmuch-search-format-mailbox-result . "")))))

  (defun m/notmuch-search-group-result (orig result)
    "Call ORIG with RESULT, adding month metadata in mailbox views."
    (if (or (not m/notmuch-search-group-by-month)
            (zerop (plist-get result :matched)))
        (funcall orig result)
      (let* ((month (format-time-string
                     "%B %Y" (seconds-to-time
                              (plist-get result :timestamp))))
             (first (null m/notmuch-search-last-month)))
        (unless (equal month m/notmuch-search-last-month)
          (setq m/notmuch-search-last-month month)
          (setq result
                (plist-put
                 result :m/notmuch-month-heading
                 (concat (unless first "\n")
                         (propertize (concat month "\n")
                                     'face
                                     'elfeed-search-separator-face)))))
        (funcall orig result))))

  (defun m/notmuch-search-display-month-heading (orig result pos)
    "Call ORIG with RESULT at POS and display its month heading."
    (prog1 (funcall orig result pos)
      (when-let* ((heading (plist-get result :m/notmuch-month-heading)))
        (remove-overlays pos (1+ pos) 'm/notmuch-month-heading t)
        (let ((overlay (make-overlay pos (1+ pos))))
          (overlay-put overlay 'm/notmuch-month-heading t)
          (overlay-put overlay 'before-string heading)
          (overlay-put overlay 'evaporate t)))))

  (defun m/notmuch-search-hide-end-message (orig proc msg)
    "Call ORIG with PROC and MSG, then remove its trailing completion message."
    (let ((buffer (process-buffer proc)))
      (prog1 (funcall orig proc msg)
        (when (buffer-live-p buffer)
          (with-current-buffer buffer
            (let ((inhibit-read-only t)
                  (message "End of search results.\n"))
              (when (and (>= (- (point-max) (length message)) (point-min))
                         (equal (buffer-substring-no-properties
                                 (- (point-max) (length message))
                                 (point-max))
                                message))
                (delete-region (- (point-max) (length message))
                               (point-max)))))))))

  (defvar-local m/notmuch-dashboard-search-widget nil
    "Search widget in the current Notmuch dashboard buffer.")

  (defun m/notmuch-hello-insert-dashboard-header ()
    "Insert the centered Notmuch dashboard title."
    (let ((dashboard-banner-logo-title "You've Got Mail!"))
      (dashboard-insert-banner-title)))

  (defun m/notmuch-hello-insert-dashboard-searches ()
    "Insert saved Notmuch searches using Dashboard styling."
    (let* ((saved-searches
            (if notmuch-saved-search-sort-function
                (funcall notmuch-saved-search-sort-function
                         notmuch-saved-searches)
              notmuch-saved-searches))
           (searches (notmuch-hello-query-counts
                      saved-searches :show-empty-searches t))
           (names (mapcar (lambda (search)
                            (capitalize (plist-get search :name)))
                          searches))
           (name-width
            (max 12 (or (cl-loop for name in names
                                 maximize (string-width name))
                        0)))
           (start (point)))
      (dashboard-insert-heading "Saved searches:")
      (cl-mapc
       (lambda (search name)
         (let* ((sort-order (plist-get search :sort-order))
                (oldest-first
                 (cl-case sort-order
                   (newest-first nil)
                   (oldest-first t)
                   (otherwise notmuch-search-oldest-first)))
                (excluded
                 (cl-case (plist-get search :excluded)
                   (hide t)
                   (show nil)
                   (otherwise notmuch-search-hide-excluded)))
                (count (notmuch-hello-nice-number
                        (plist-get search :count)))
                (line (concat
                       "    " name
                       (make-string
                        (max 1 (- name-width (string-width name))) ?\s)
                       (format "%9s" count))))
           (widget-insert "\n")
           (widget-create
            'item
            :tag line
            :value name
            :action #'notmuch-hello-widget-search
            :button-face 'dashboard-items-face
            :mouse-face 'highlight
            :button-prefix ""
            :button-suffix ""
            :format "%[%t%]"
            :notmuch-search-terms (plist-get search :query)
            :notmuch-search-oldest-first oldest-first
            :notmuch-search-type (plist-get search :search-type)
            :notmuch-search-hide-excluded excluded)))
       searches names)
      (widget-insert "\n")
      (dashboard-center-text start (point))))

  (defun m/notmuch-hello-insert-dashboard-search ()
    "Insert a centered mail search widget using Dashboard styling."
    (let ((start (point))
          (field-width (max 16 (min 48 (- (window-width) 12)))))
      (dashboard-insert-heading "Search:")
      (widget-insert "\n    ")
      (setq m/notmuch-dashboard-search-widget
            (widget-create 'editable-field
                           :size field-width
                           :action #'notmuch-hello-search))
      (widget-insert (propertize "." 'invisible t))
      (widget-insert "\n")
      (dashboard-center-text start (point))))

  (defun m/notmuch-name-show-buffer ()
    "Use `View' as the sole Notmuch show buffer."
    (when-let* ((buffer (get-buffer "View")))
      (unless (eq buffer (current-buffer))
        (kill-buffer buffer)))
    (rename-buffer "View"))

  (defun m/notmuch-set-mode-name ()
    "Display the current Notmuch major mode as `Notmuch'."
    (setq-local mode-name "Notmuch"))

  (defun m/notmuch-show-use-header-address-faces ()
    "Keep address buttonization from overriding message header faces."
    (setq-local goto-address-mail-face nil))

  (defun m/notmuch-hello-focus-search ()
    "Move to the dashboard search field and enter Evil Insert state."
    (interactive)
    (unless (and m/notmuch-dashboard-search-widget
                 (eq (widget-field-buffer
                      m/notmuch-dashboard-search-widget)
                     (current-buffer)))
      (user-error "The Notmuch search field is unavailable"))
    (goto-char (widget-field-start m/notmuch-dashboard-search-widget))
    (evil-insert-state))

  (defun m/notmuch-hello-set-local-bindings ()
    "Set local Evil bindings for the Notmuch dashboard."
    (evil-local-set-key 'normal (kbd "/")
                        #'m/notmuch-hello-focus-search)
    (evil-local-set-key 'normal (kbd "q") #'quit-window))

  (defun m/notmuch-open-mailbox (query &optional show-excluded)
    "Open the mailbox matching QUERY and kill the previous Notmuch buffer.
Show excluded messages when SHOW-EXCLUDED is non-nil. Preserve a previous
buffer that is visible in more than one window, as Dired does."
    (let* ((origin (current-buffer))
           (kill-origin
            (and (derived-mode-p 'notmuch-hello-mode
                                 'notmuch-search-mode
                                 'notmuch-show-mode)
                 (< (length (get-buffer-window-list origin)) 2))))
      (notmuch-search query
                      (default-value 'notmuch-search-oldest-first)
                      (and (not show-excluded)
                           (default-value 'notmuch-search-hide-excluded)))
      (when (and kill-origin
                 (buffer-live-p origin)
                 (not (eq origin (current-buffer))))
        (kill-buffer origin))))

  (defun m/notmuch-open-inbox ()
    "Open the Gmail Inbox."
    (interactive)
    (m/notmuch-open-mailbox "tag:inbox"))

  (defun m/notmuch-open-trash ()
    "Open Gmail Trash."
    (interactive)
    (m/notmuch-open-mailbox "tag:trash" t))

  (defun m/notmuch-open-spam ()
    "Open Gmail Spam."
    (interactive)
    (m/notmuch-open-mailbox "tag:spam" t))

  (defun m/notmuch-open-sent ()
    "Open Gmail Sent."
    (interactive)
    (m/notmuch-open-mailbox "tag:sent"))

  (defun m/notmuch-open-starred ()
    "Open Gmail Starred."
    (interactive)
    (m/notmuch-open-mailbox "tag:flagged"))

  (defun m/notmuch-open-drafts ()
    "Open Gmail Drafts."
    (interactive)
    (m/notmuch-open-mailbox "tag:draft"))

  (defun m/notmuch-set-mailbox-bindings ()
    "Set Gmail-style mailbox bindings in the current Notmuch buffer."
    (evil-local-set-key 'normal (kbd "g i") #'m/notmuch-open-inbox)
    (evil-local-set-key 'normal (kbd "g #") #'m/notmuch-open-trash)
    (evil-local-set-key 'normal (kbd "g !") #'m/notmuch-open-spam)
    (evil-local-set-key 'normal (kbd "g t") #'m/notmuch-open-sent)
    (evil-local-set-key 'normal (kbd "g s") #'m/notmuch-open-starred)
    (evil-local-set-key 'normal (kbd "g d") #'m/notmuch-open-drafts))

  (defun m/notmuch-unread-tag-change (tags)
    "Return the tag change that toggles `unread' in TAGS."
    (list (if (member "unread" tags) "-unread" "+unread")))

  (defun m/notmuch-search-toggle-unread (beg end)
    "Toggle unread for the selected threads between BEG and END."
    (interactive (notmuch-interactive-region))
    (notmuch-search-tag
     (m/notmuch-unread-tag-change
      (notmuch-search-get-tags-region beg end))
     beg end))

  (defun m/notmuch-show-toggle-unread ()
    "Toggle unread for all messages in the current thread."
    (interactive)
    (let (tags)
      (notmuch-show-mapc
       (lambda ()
         (setq tags (append (notmuch-show-get-tags) tags))))
      (notmuch-show-tag-all (m/notmuch-unread-tag-change tags))))

  (defun m/notmuch-search-trash (beg end)
    "Move the selected threads between BEG and END to Gmail Trash."
    (interactive (notmuch-interactive-region))
    (notmuch-search-tag '("+trash" "-inbox" "-unread") beg end)
    (when (= beg end)
      (notmuch-search-next-thread)))

  (defun m/notmuch-show-trash ()
    "Move all displayed messages in the current thread to Gmail Trash."
    (interactive)
    (notmuch-show-tag-all '("+trash" "-inbox" "-unread"))
    (notmuch-show-next-thread t))

  (defun m/notmuch-search-set-local-bindings ()
    "Set local Evil bindings for a Notmuch search view."
    (evil-local-set-key 'normal (kbd "#") #'m/notmuch-search-trash)
    (evil-local-set-key 'visual (kbd "#") #'m/notmuch-search-trash)
    (evil-local-set-key 'normal (kbd "U") #'m/notmuch-search-toggle-unread)
    (evil-local-set-key 'visual (kbd "U") #'m/notmuch-search-toggle-unread))

  (defun m/notmuch-show-set-local-bindings ()
    "Set local Evil bindings for a Notmuch message view."
    (evil-local-set-key 'normal (kbd "#") #'m/notmuch-show-trash)
    (evil-local-set-key 'normal (kbd "H") #'m/notmuch-show-toggle-html)
    (evil-local-set-key 'normal (kbd "U") #'m/notmuch-show-toggle-unread))

  (defun m/notmuch-show-html-button ()
    "Return the HTML alternative button in the current message, if any."
    (let* ((extent (notmuch-show-message-extent))
           (position (car extent))
           button)
      (catch 'found
        (while (and (< position (cdr extent))
                    (setq button (next-button position t))
                    (< (button-start button) (cdr extent)))
          (let* ((part (get-text-property (button-start button)
                                          :notmuch-part))
                 (type (plist-get part :computed-type)))
            (when (member type '("text/html" "multipart/related"))
              (throw 'found button)))
          (setq position (button-end button)))
        nil)))

  (defun m/notmuch-show-toggle-html ()
    "Toggle the HTML alternative for the message at point."
    (interactive)
    (if-let* ((button (m/notmuch-show-html-button)))
        (let ((show (button-get button :notmuch-part-hidden)))
          (notmuch-show-toggle-part-invisibility button)
          (message "HTML alternative %s" (if show "shown" "hidden")))
      (user-error "This message has no HTML alternative")))

  (defconst m/notmuch-link-display-width 40
    "Maximum preferred display width for plain-text HTTP links.")

  (defun m/notmuch-truncate-link-component (component width keep-end)
    "Truncate COMPONENT to WIDTH, retaining its end when KEEP-END is non-nil."
    (cond
     ((<= (length component) width) component)
     ((<= width 1) "…")
     (keep-end (concat "…" (substring component (- (1- width)))))
     (t (concat (substring component 0 (1- width)) "…"))))

  (defun m/notmuch-truncate-link-middle (component width)
    "Truncate the middle of COMPONENT to WIDTH."
    (if (<= (length component) width)
        component
      (let* ((remaining (max 0 (1- width)))
             (left (/ (1+ remaining) 2))
             (right (- remaining left)))
        (concat (substring component 0 left) "…"
                (if (zerop right) "" (substring component (- right)))))))

  (defun m/notmuch-compact-link (url)
    "Return a compact display string for URL without changing its target."
    (if (or (<= (string-width url) m/notmuch-link-display-width)
            (not (string-match
                  "\\`\\(https?://[^/?#[:space:]]+\\)\\([^?#]*\\)" url)))
        url
      (let* ((base (match-string 1 url))
             (path (match-string 2 url))
             (tail (substring url (match-end 2)))
             (components (split-string path "/" t))
             (base-width (string-width base))
             (available (max 2 (- m/notmuch-link-display-width
                                  base-width 4)))
             (first-width (/ (1+ available) 2))
             (last-width (max 1 (- available first-width))))
        (cond
         ((>= (length components) 2)
          (format "%s/%s/…/%s"
                  base
                  (m/notmuch-truncate-link-component
                   (car components) first-width nil)
                  (m/notmuch-truncate-link-component
                   (car (last components)) last-width t)))
         ((= (length components) 1)
          (let* ((component (car components))
                 (compact (m/notmuch-truncate-link-middle
                           component
                           (max 1 (- m/notmuch-link-display-width
                                     base-width 1)))))
            (concat base "/" compact
                    (if (or (not (equal compact component))
                            (equal tail ""))
                        ""
                      (if (string-prefix-p "#" tail) "#…" "?…")))))
         ((equal tail "") url)
         (t (concat base "/…"))))))

  (defun m/notmuch-truncate-plain-text-links (_msg _depth)
    "Display long HTTP links compactly in the current plain-text MIME part."
    (save-excursion
      (goto-char (point-min))
      (let ((case-fold-search t))
        (while (re-search-forward goto-address-url-regexp nil t)
          (let* ((start (match-beginning 0))
                 (end (match-end 0))
                 (url (match-string-no-properties 0))
                 (compact (and (string-match-p "\\`https?://" url)
                               (m/notmuch-compact-link url))))
            (when (and compact
                       (not (equal compact url))
                       (not (text-property-not-all start end 'display nil)))
              (add-text-properties
               start end `(display ,compact help-echo ,url))))))))

  (defun m/notmuch-format-labels (tags &optional orig-tags)
    "Format TAGS as a comma-separated list relative to ORIG-TAGS."
    (let* ((orig-tags (or orig-tags tags))
           (all-tags (sort (delete-dups (append tags orig-tags nil))
                           #'string<))
           (formatted-tags
            (delq nil
                  (mapcar (apply-partially #'notmuch-tag-format-tag
                                           tags orig-tags)
                          all-tags))))
      (notmuch-apply-face (mapconcat #'identity formatted-tags ", ")
                          'notmuch-tag-face t)))

  (defun m/notmuch-show-insert-from-line
      (msg-plist depth _tags &optional _orig-tags)
    "Insert a From-only summary line for MSG-PLIST at thread DEPTH."
    (let* ((start (point))
           (headers (plist-get msg-plist :headers))
           (from (notmuch-sanitize
                  (notmuch-show-clean-address
                   (plist-get headers :From)))))
      (insert (if notmuch-show-indent-content
                  (notmuch-show-spaces-n
                   (* notmuch-show-indent-messages-width depth))
                "")
              "From:")
      (overlay-put (make-overlay start (point))
                   'face 'message-header-name)
      (let ((value-start (point)))
        (insert " " from "\n")
        (overlay-put (make-overlay value-start (point))
                     'face 'message-header-other))))

  (defun m/notmuch-show-add-labels-header (orig msg depth)
    "Call ORIG with MSG at DEPTH after adding its synthetic Labels header."
    (let* ((msg (copy-sequence msg))
           (headers (copy-sequence (plist-get msg :headers)))
           (labels (m/notmuch-format-labels (plist-get msg :tags))))
      (setq headers (plist-put headers :Labels labels))
      (setq msg (plist-put msg :headers headers))
      (funcall orig msg depth)))

  (defun m/notmuch-show-update-labels-header (orig tags)
    "Call ORIG with TAGS, then update the current message's Labels header."
    (prog1 (funcall orig tags)
      (let ((extent (notmuch-show-message-extent))
            (labels (m/notmuch-format-labels
                     tags (notmuch-show-get-prop :orig-tags)))
            (inhibit-read-only t))
        (save-excursion
          (save-restriction
            (narrow-to-region (car extent) (cdr extent))
            (goto-char (point-min))
            (when (re-search-forward "^Labels: \\(.*\\)$" nil t)
              (let ((start (match-beginning 1))
                    (end (match-end 1)))
                (delete-region start end)
                (goto-char start)
                (insert labels))))))))

  (defvar m/notmuch-dashboard-rename-depth 0
    "Current nesting depth while temporarily naming the Notmuch dashboard.")

  (defun m/notmuch-dashboard-buffer-name (orig &rest args)
    "Call ORIG with ARGS while preserving the dashboard buffer name."
    (let ((outermost (zerop m/notmuch-dashboard-rename-depth))
          (m/notmuch-dashboard-rename-depth
           (1+ m/notmuch-dashboard-rename-depth)))
      (when outermost
        (when-let* ((buffer (get-buffer "Dashboard")))
          (with-current-buffer buffer
            (rename-buffer "*notmuch-hello*"))))
      (unwind-protect
          (apply orig args)
        (when outermost
          (when-let* ((buffer (get-buffer "*notmuch-hello*")))
            (with-current-buffer buffer
              (rename-buffer "Dashboard")))))))

  :custom
  (mail-user-agent 'notmuch-user-agent)
  (message-send-mail-function 'message-send-mail-with-sendmail)
  (message-sendmail-envelope-from 'header)
  (sendmail-program "notmuch-sendmail")

  ;; Prefer plain text and offer HTML only on demand. The visible Subject
  ;; header makes Notmuch's separate subject header line redundant.
  (notmuch-message-headers '("Subject" "To" "Cc" "Date" "Labels"))
  (notmuch-multipart/alternative-discouraged
   '("text/html" "multipart/related"))
  (notmuch-show-header-line nil)

  ;; Gmail creates and indexes the Sent copy after sending through its API.
  ;; A local Fcc would create a duplicate that Lieer cannot upload.
  (notmuch-fcc-dirs nil)
  (notmuch-poll-script "notmuch-sync")
  (notmuch-search-buffer-name-format "Search: %s")
  (notmuch-search-oldest-first nil)
  (notmuch-show-logo nil)

  ;; Use Gmail's Starred terminology while retaining Lieer's `flagged' tag.
  (notmuch-saved-searches
   `((:name "inbox" :query "tag:inbox" :key ,(kbd "i"))
     (:name "unread" :query "tag:unread" :key ,(kbd "u"))
     (:name "starred" :query "tag:flagged" :key ,(kbd "f"))
     (:name "sent" :query "tag:sent" :key ,(kbd "t"))
     (:name "drafts" :query "tag:draft" :key ,(kbd "d"))
     (:name "all mail" :query "*" :key ,(kbd "a"))))
  (notmuch-hello-sections
   '(m/notmuch-hello-insert-dashboard-header
     m/notmuch-hello-insert-dashboard-searches
     m/notmuch-hello-insert-dashboard-search))

  ;; Lieer maps these tags bidirectionally to Gmail system labels. In
  ;; particular, use `trash' rather than Notmuch's local-only `deleted' tag.
  (notmuch-tagging-keys
   `((,(kbd "a") notmuch-archive-tags "Archive")
     (,(kbd "u") notmuch-show-mark-read-tags "Mark read")
     (,(kbd "f") ("+flagged") "Flag")
     (,(kbd "s") ("+spam" "-inbox") "Mark as spam")
     (,(kbd "d") ("+trash" "-inbox" "-unread") "Move to trash")))

  :hook
  ((notmuch-hello-mode . m/notmuch-hello-set-local-bindings)
   (notmuch-hello-mode . m/notmuch-set-mailbox-bindings)
   (notmuch-hello-mode . m/notmuch-set-mode-name)
   (notmuch-search-mode . m/notmuch-mailbox-layout)
   (notmuch-search-mode . m/notmuch-set-mailbox-bindings)
   (notmuch-search-mode . m/notmuch-search-set-local-bindings)
   (notmuch-search-mode . m/notmuch-set-mode-name)
   (notmuch-show-mode . m/notmuch-set-mailbox-bindings)
   (notmuch-show-mode . m/notmuch-set-mode-name)
   (notmuch-show-mode . m/notmuch-show-set-local-bindings)
   (notmuch-show-mode . m/notmuch-show-use-header-address-faces))

  :general
  ("SPC m" '(notmuch :which-key "Mail"))

  :config
  ;; Share Elfeed's bold, underlined date-separator styling.
  (require 'elfeed-search)

  ;; Ef themes use a wavy underline for deleted tags. Restore Notmuch's
  ;; strike-through convention while preserving the theme's foreground color.
  (custom-set-faces
   '(notmuch-tag-deleted ((t (:underline nil :strike-through t)))))

  (advice-add 'notmuch-search-append-result
              :around #'m/notmuch-search-group-result)
  (advice-add 'notmuch-search-buffer-title
              :around #'m/notmuch-search-buffer-title)
  (advice-add 'notmuch-search-show-result
              :around #'m/notmuch-search-display-month-heading)
  (advice-add 'notmuch-search-process-sentinel
              :around #'m/notmuch-search-hide-end-message)
  (advice-add 'notmuch-hello
              :around #'m/notmuch-dashboard-buffer-name)
  (advice-add 'notmuch-hello-window-configuration-change
              :around #'m/notmuch-dashboard-buffer-name)
  (advice-add 'notmuch-show-insert-headerline
              :override #'m/notmuch-show-insert-from-line)
  (advice-add 'notmuch-show-insert-msg
              :around #'m/notmuch-show-add-labels-header)
  (advice-add 'notmuch-show-update-tags
              :around #'m/notmuch-show-update-labels-header)
  (add-hook 'notmuch-show-insert-text/plain-hook
            #'m/notmuch-truncate-plain-text-links t)
  (add-hook 'notmuch-show-hook #'m/notmuch-name-show-buffer))

(with-eval-after-load 'evil-collection
  (evil-collection-init 'notmuch))

;;; notmuch.el ends here
