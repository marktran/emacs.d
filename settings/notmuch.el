;;; notmuch.el --- Gmail with Notmuch on Linux

;; Emacs frontend settings for the local Notmuch mail index. System
;; installation, Gmail authorization, background synchronization, and
;; troubleshooting are documented in the parent dotfiles repository at
;; docs/EMACS.md.
;;
;; `SPC m' opens the Inbox directly. `M-x notmuch' opens the optional Notmuch
;; home screen in `Dashboard', which shares the main Emacs dashboard's centered
;; title and section styling. `/` moves to its search box and enters Insert
;; state. Inbox, Trash, Spam, Sent,
;; Starred, and Drafts searches use matching buffer names; other queries use
;; `Search: query', and opened threads use `View'.
;; Mailbox and ad hoc search results show From, Subject, and Date without thread
;; counts. Inbox, Trash, and Spam are grouped by month and year. Today's
;; messages show their time; older messages use `Month Day'.
;; Message summary lines display the sender as `From:' and comma-separated tags
;; as `Labels:'. `U' toggles read/unread, `s' toggles Starred, `e' archives, and
;; `d' and `u' scroll down and up. `g i', `g #', `g !', `g t', `g s',
;; and `g d' open Inbox, Trash, Spam, Sent, Starred, and Drafts, replacing the
;; current Notmuch buffer. `/` starts an ad hoc search from content views.
;; `r' invokes `notmuch-sync' and refreshes the view; normal background
;; synchronization does not require Emacs to be running.
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
;; Gmail labels appear as Notmuch tags. Archiving removes `inbox'. `#' moves
;; selected threads to `trash', while `!' moves them to `spam'; both request an
;; immediate background sync. The tag menu also uses `trash' instead of
;; Notmuch's internal `deleted' tag so deletions
;; propagate to Gmail during synchronization. The dashboard, search, and
;; message views all display `Notmuch' as their major-mode name.

(use-package notmuch
  :ensure t
  :after dashboard
  :commands notmuch

  :preface
  (defconst m/notmuch-mailboxes
    '(("Inbox"   "tag:inbox"   "g i" grouped)
      ("Trash"   "tag:trash"   "g #" grouped show-excluded)
      ("Spam"    "tag:spam"    "g !" grouped show-excluded)
      ("Sent"    "tag:sent"    "g t")
      ("Starred" "tag:flagged" "g s")
      ("Drafts"  "tag:draft"   "g d"))
    "Gmail mailboxes as (NAME QUERY KEY . FLAGS) entries.
NAME is the search buffer name, QUERY the exact Notmuch query, and KEY
the binding that opens the mailbox. The `grouped' flag groups results
by month and year, and `show-excluded' includes messages with excluded
tags.")

  (defun m/notmuch-search-buffer-title (orig query &optional type)
    "Give exact mailbox QUERY values concise names.
Call ORIG with QUERY and TYPE for all other searches."
    (or (car (seq-find (lambda (mailbox) (equal (nth 1 mailbox) query))
                       m/notmuch-mailboxes))
        (funcall orig query type)))

  (defun m/notmuch-bind-keys (states bindings)
    "Locally bind BINDINGS, a list of (KEY . COMMAND) pairs, in Evil STATES."
    (pcase-dolist (`(,key . ,command) bindings)
      (dolist (state states)
        (evil-local-set-key state (kbd key) command))))

  (defvar-local m/notmuch-search-group-by-month nil
    "Whether the current search groups results by month.")

  (defvar m/notmuch-sync-process nil
    "Active asynchronous Gmail synchronization process.")

  (defvar m/notmuch-sync-timer nil
    "Timer waiting to start an asynchronous Gmail synchronization.")

  (defvar m/notmuch-sync-pending nil
    "Whether another Gmail synchronization is needed.")

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
    (let ((mailbox (assoc (buffer-name) m/notmuch-mailboxes)))
      (when (or mailbox (string-prefix-p "Search: " (buffer-name)))
        (setq-local m/notmuch-search-group-by-month
                    (and (memq 'grouped mailbox) t))
        (setq-local m/notmuch-search-last-month nil)
        (setq-local notmuch-search-result-format
                    '((m/notmuch-search-format-mailbox-result . ""))))))

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
                  (suffix "End of search results.\n"))
              (when (and (>= (- (point-max) (length suffix)) (point-min))
                         (equal (buffer-substring-no-properties
                                 (- (point-max) (length suffix))
                                 (point-max))
                                suffix))
                (delete-region (- (point-max) (length suffix))
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
    "Display a concise mode line in the current Notmuch buffer."
    (setq-local mode-name "Notmuch"
                mode-line-modified nil
                mode-line-mule-info nil
                mode-line-remote nil))

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
    (m/notmuch-bind-keys '(normal)
                         '(("/" . m/notmuch-hello-focus-search)
                           ("q" . quit-window))))

  (defun m/notmuch-open-mailbox (name)
    "Open the Gmail mailbox NAME and kill the previous Notmuch buffer.
Preserve a previous buffer that is visible in more than one window, as
Dired does."
    (let* ((mailbox (assoc name m/notmuch-mailboxes))
           (origin (current-buffer))
           (kill-origin
            (and (derived-mode-p 'notmuch-hello-mode
                                 'notmuch-search-mode
                                 'notmuch-show-mode)
                 (< (length (get-buffer-window-list origin)) 2))))
      (notmuch-search (nth 1 mailbox)
                      (default-value 'notmuch-search-oldest-first)
                      (and (not (memq 'show-excluded mailbox))
                           (default-value 'notmuch-search-hide-excluded)))
      (when (and kill-origin
                 (buffer-live-p origin)
                 (not (eq origin (current-buffer))))
        (kill-buffer origin))))

  (defun m/notmuch-open-mailbox-command (name)
    "Return the command symbol that opens the mailbox NAME."
    (intern (format "m/notmuch-open-%s" (downcase name))))

  ;; Define `m/notmuch-open-inbox' and friends for each mailbox.
  (dolist (mailbox m/notmuch-mailboxes)
    (let ((name (car mailbox)))
      (defalias (m/notmuch-open-mailbox-command name)
        `(lambda ()
           (interactive)
           (m/notmuch-open-mailbox ,name))
        (format "Open Gmail %s." name))))

  (defun m/notmuch-set-mailbox-bindings ()
    "Set Gmail-style mailbox bindings in the current Notmuch buffer."
    (dolist (mailbox m/notmuch-mailboxes)
      (evil-local-set-key 'normal (kbd (nth 2 mailbox))
                          (m/notmuch-open-mailbox-command (car mailbox)))))

  (defun m/notmuch-set-refresh-bindings (mode _keymaps)
    "Set concise refresh bindings after evil-collection sets up MODE."
    (when (eq mode 'notmuch)
      (evil-define-key 'normal notmuch-common-keymap
        (kbd "g r") nil
        (kbd "g R") nil
        (kbd "r") #'notmuch-poll-and-refresh-this-buffer)))

  (defun m/notmuch-sync-start ()
    "Start a requested asynchronous Gmail synchronization."
    (setq m/notmuch-sync-timer nil)
    (when (and m/notmuch-sync-pending
               (not (process-live-p m/notmuch-sync-process)))
      (setq m/notmuch-sync-pending nil)
      (let ((buffer (get-buffer-create " *notmuch Gmail sync*")))
        (with-current-buffer buffer
          (erase-buffer))
        (condition-case error
            (setq m/notmuch-sync-process
                  (make-process
                   :name "notmuch-gmail-sync"
                   :buffer buffer
                   :command '("notmuch-sync")
                   :connection-type 'pipe
                   :noquery t
                   :sentinel #'m/notmuch-sync-sentinel
                   :stderr buffer))
          (error
           (kill-buffer buffer)
           (display-warning
            'notmuch
            (format "Could not start Gmail synchronization: %s"
                    (error-message-string error))))))))

  (defun m/notmuch-sync-request ()
    "Request a debounced asynchronous Gmail synchronization."
    (setq m/notmuch-sync-pending t)
    (when (timerp m/notmuch-sync-timer)
      (cancel-timer m/notmuch-sync-timer))
    (unless (process-live-p m/notmuch-sync-process)
      (setq m/notmuch-sync-timer
            (run-at-time 0.5 nil #'m/notmuch-sync-start))))

  (defun m/notmuch-sync-sentinel (process _event)
    "Handle completion of asynchronous Gmail sync PROCESS."
    (when (memq (process-status process) '(exit signal))
      (let* ((buffer (process-buffer process))
             (output (if (buffer-live-p buffer)
                         (with-current-buffer buffer
                           (string-trim (buffer-string)))
                       ""))
             (success (and (eq (process-status process) 'exit)
                           (zerop (process-exit-status process))))
             (repository-busy
              (string-match-p "failed to lock repository" output)))
        (when (eq process m/notmuch-sync-process)
          (setq m/notmuch-sync-process nil))
        (when (buffer-live-p buffer)
          (kill-buffer buffer))
        (cond
         (success
          (notmuch-refresh-all-buffers))
         (repository-busy
          (setq m/notmuch-sync-pending t))
         (t
          (display-warning
           'notmuch
           (format "Gmail synchronization failed%s"
                   (if (string-empty-p output)
                       ""
                     (concat ": " output))))))
        (when m/notmuch-sync-pending
          (m/notmuch-sync-request)))))

  (defun m/notmuch-toggle-tag-change (tag tags)
    "Return the tag change that toggles TAG in TAGS."
    (list (concat (if (member tag tags) "-" "+") tag)))

  (defun m/notmuch-search-toggle-unread (beg end)
    "Toggle unread for the selected threads between BEG and END."
    (interactive (notmuch-interactive-region))
    (notmuch-search-tag
     (m/notmuch-toggle-tag-change
      "unread" (notmuch-search-get-tags-region beg end))
     beg end))

  (defun m/notmuch-show-toggle-unread ()
    "Toggle unread for all messages in the current thread."
    (interactive)
    (let (tags)
      (notmuch-show-mapc
       (lambda ()
         (setq tags (append (notmuch-show-get-tags) tags))))
      (notmuch-show-tag-all (m/notmuch-toggle-tag-change "unread" tags))))

  (defun m/notmuch-search-finish-move (beg end)
    "Update the search view after moving threads between BEG and END."
    (if (equal notmuch-search-query-string "tag:inbox")
        ;; Re-run only the local query so moved threads disappear without
        ;; waiting for Gmail synchronization to finish.
        (notmuch-search-refresh-view)
      (when (= beg end)
        (notmuch-search-next-thread))))

  (defun m/notmuch-search-move (tag-changes beg end)
    "Apply TAG-CHANGES between BEG and END, sync, and update the view."
    (notmuch-search-tag tag-changes beg end)
    (m/notmuch-sync-request)
    (m/notmuch-search-finish-move beg end))

  (defun m/notmuch-show-move (tag-changes)
    "Apply TAG-CHANGES to the whole thread, sync, and show the next thread."
    (notmuch-show-tag-all tag-changes)
    (m/notmuch-sync-request)
    (notmuch-show-next-thread t))

  (defun m/notmuch-search-archive (beg end)
    "Archive the selected threads between BEG and END in Gmail."
    (interactive (notmuch-interactive-region))
    (m/notmuch-search-move '("-inbox") beg end))

  (defun m/notmuch-show-archive ()
    "Archive all displayed messages in the current Gmail thread."
    (interactive)
    (m/notmuch-show-move '("-inbox")))

  (defun m/notmuch-search-trash (beg end)
    "Move the selected threads between BEG and END to Gmail Trash."
    (interactive (notmuch-interactive-region))
    (m/notmuch-search-move '("+trash" "-inbox" "-unread") beg end))

  (defun m/notmuch-show-trash ()
    "Move all displayed messages in the current thread to Gmail Trash."
    (interactive)
    (m/notmuch-show-move '("+trash" "-inbox" "-unread")))

  (defun m/notmuch-search-spam (beg end)
    "Move the selected threads between BEG and END to Gmail Spam."
    (interactive (notmuch-interactive-region))
    (m/notmuch-search-move '("+spam" "-inbox" "-unread" "-trash") beg end))

  (defun m/notmuch-show-spam ()
    "Move all displayed messages in the current thread to Gmail Spam."
    (interactive)
    (m/notmuch-show-move '("+spam" "-inbox" "-unread" "-trash")))

  (defun m/notmuch-search-star (beg end)
    "Toggle Starred on the selected threads between BEG and END."
    (interactive (notmuch-interactive-region))
    (notmuch-search-tag
     (m/notmuch-toggle-tag-change
      "flagged" (notmuch-search-get-tags-region beg end))
     beg end)
    (m/notmuch-sync-request))

  (defun m/notmuch-show-star ()
    "Toggle Starred on the current message."
    (interactive)
    (notmuch-show-tag
     (m/notmuch-toggle-tag-change "flagged" (notmuch-show-get-tags)))
    (m/notmuch-sync-request))

  (defun m/notmuch-inhibit-archive-bindings (keys)
    "Prevent KEYS from invoking alternate archive commands."
    (dolist (key keys)
      (local-set-key (kbd key) #'ignore)
      (dolist (state '(normal visual))
        (evil-local-set-key state (kbd key) #'ignore))))

  (defun m/notmuch-search-set-local-bindings ()
    "Set local Evil bindings for a Notmuch search view."
    (m/notmuch-bind-keys '(normal visual)
                         '(("#" . m/notmuch-search-trash)
                           ("!" . m/notmuch-search-spam)
                           ("U" . m/notmuch-search-toggle-unread)
                           ("s" . m/notmuch-search-star)
                           ("e" . m/notmuch-search-archive)))
    (m/notmuch-bind-keys '(normal) '(("/" . notmuch-search)))
    (m/notmuch-inhibit-archive-bindings '("a")))

  (defun m/notmuch-show-set-local-bindings ()
    "Set local Evil bindings for a Notmuch message view."
    (m/notmuch-bind-keys '(normal)
                         '(("#" . m/notmuch-show-trash)
                           ("!" . m/notmuch-show-spam)
                           ("H" . m/notmuch-show-toggle-html)
                           ("U" . m/notmuch-show-toggle-unread)
                           ("s" . m/notmuch-show-star)
                           ("e" . m/notmuch-show-archive)
                           ("/" . notmuch-search)))
    (m/notmuch-inhibit-archive-bindings '("a" "A" "x" "X"))
    (local-set-key (kbd "SPC") #'scroll-up-command))

  (defun m/notmuch-tree-archive ()
    "Archive the current Notmuch tree thread and select the next one."
    (interactive)
    (notmuch-tree-archive-thread-then-next)
    (m/notmuch-sync-request))

  (defun m/notmuch-tree-set-local-bindings ()
    "Set local Evil bindings for a Notmuch tree view."
    (m/notmuch-bind-keys '(normal)
                         '(("e" . m/notmuch-tree-archive)
                           ("/" . notmuch-search)))
    (m/notmuch-inhibit-archive-bindings '("a" "A" "x" "X")))

  (defun m/notmuch-set-scroll-bindings ()
    "Use consistent Evil scrolling in Notmuch content views."
    (m/notmuch-bind-keys '(normal visual)
                         '(("d" . evil-scroll-down)
                           ("u" . evil-scroll-up))))

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

  :init
  (add-hook 'evil-collection-setup-hook #'m/notmuch-set-refresh-bindings)

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
  ;; particular, use `trash' rather than Notmuch's internal `deleted' tag.
  (notmuch-tagging-keys
   `((,(kbd "u") notmuch-show-mark-read-tags "Mark read")
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
   (notmuch-search-mode . m/notmuch-set-scroll-bindings)
   (notmuch-search-mode . m/notmuch-set-mode-name)
   (notmuch-show-mode . m/notmuch-set-mailbox-bindings)
   (notmuch-show-mode . m/notmuch-set-mode-name)
   (notmuch-show-mode . m/notmuch-show-set-local-bindings)
   (notmuch-show-mode . m/notmuch-set-scroll-bindings)
   (notmuch-show-mode . m/notmuch-show-use-header-address-faces)
   (notmuch-tree-mode . m/notmuch-set-scroll-bindings)
   (notmuch-tree-mode . m/notmuch-tree-set-local-bindings))

  :general
  ("SPC m" '(m/notmuch-open-inbox :which-key "Mail inbox"))

  :config
  ;; Share Elfeed's bold, underlined date-separator styling.
  (require 'elfeed-search)

  ;; Ef themes use a wavy underline for deleted tags. Restore Notmuch's
  ;; strike-through convention while preserving the theme's foreground color.
  (custom-set-faces
   '(notmuch-tag-deleted ((t (:underline nil :strike-through t))))
   '(shr-text ((t (:inherit default)))))

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

(use-package consult-notmuch
  :ensure t
  :after (consult notmuch)
  :commands (consult-notmuch consult-notmuch-address consult-notmuch-tree)

  :general
  ("SPC s m" '(consult-notmuch :which-key "Search mail")))

(with-eval-after-load 'evil-collection
  (evil-collection-init 'notmuch))
