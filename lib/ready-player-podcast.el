;;; ready-player-podcast.el --- Play podcast episodes with ready-player

;; Subscriptions live in `ready-player-podcast-feeds', an alist mapping
;; a podcast name to its RSS feed URL. `ready-player-podcast' picks a
;; podcast (skipping the prompt when there is only one), fetches its
;; feed, and offers the episodes newest first, grouped by publication
;; month, with each episode's duration shown against the right edge of
;; the minibuffer. Choosing an episode plays it through ready-player
;; (via `ready-player-autoplay') in the background — the player buffer
;; is created but not displayed; `ready-player-view-player' brings it
;; up. With a prefix argument the episode is only downloaded for later
;; listening.
;;
;; ready-player only plays local files, so episodes are downloaded
;; into `ready-player-podcast-directory' (one subdirectory per
;; podcast, files prefixed with the publication date so directory
;; order is chronological) and reused on later plays. Downloads run
;; asynchronously through curl with a browser User-Agent —
;; Buzzsprout's CDN returns 403 for curl's own. Episode metadata and
;; cover art come from the downloaded files' ID3 tags, which
;; ready-player reads with ffprobe.

(require 'subr-x)
(require 'url)
(require 'url-handlers)
(require 'url-parse)
(require 'xml)

(defgroup ready-player-podcast nil
  "Play podcast episodes with ready-player."
  :group 'ready-player
  :prefix "ready-player-podcast-")

(defcustom ready-player-podcast-feeds nil
  "Podcast subscriptions as an alist of (NAME . RSS-FEED-URL)."
  :group 'ready-player-podcast
  :type '(alist :key-type (string :tag "Name")
                :value-type (string :tag "Feed URL")))

(defcustom ready-player-podcast-directory
  (locate-user-emacs-file "podcasts")
  "Directory where downloaded episodes are kept."
  :group 'ready-player-podcast
  :type 'directory)

(defcustom ready-player-podcast-user-agent "Mozilla/5.0"
  "User-Agent header for episode downloads.
Podcast CDNs like Buzzsprout's reject curl's default User-Agent
with a 403."
  :group 'ready-player-podcast
  :type 'string)

(defvar ready-player-podcast--candidates nil
  "Completion candidates for the current episode prompt.
An alist of (TITLE . EPISODE), where EPISODE is a plist as returned
by `ready-player-podcast--episodes'.")

(defvar ready-player-podcast--duration-width 0
  "Width of the widest formatted duration in the current candidates.
Episode annotations pad durations to this width so the duration
column stays aligned.")

(defvar ready-player-podcast--downloads nil
  "In-flight episode downloads, an alist of (FILE . PROCESS).")

(defun ready-player-podcast--child-text (node name)
  "Return the trimmed text of NODE's first NAME child, or nil."
  (let ((text (string-trim
               (mapconcat (lambda (child) (if (stringp child) child ""))
                          (xml-node-children
                           (car (xml-get-children node name)))
                          ""))))
    (unless (string-empty-p text)
      text)))

(defun ready-player-podcast--date (text)
  "Return RSS pubDate TEXT as YYYY-MM-DD, or nil."
  (when text
    (condition-case nil
        (format-time-string "%Y-%m-%d" (date-to-time text))
      (error nil))))

(defun ready-player-podcast--month (text)
  "Return RSS pubDate TEXT as a month heading like \"July 2026\"."
  (when text
    (condition-case nil
        (format-time-string "%B %Y" (date-to-time text))
      (error nil))))

(defun ready-player-podcast--duration-seconds (text)
  "Return itunes:duration TEXT (seconds or H:MM:SS) as whole seconds."
  (when (and text (string-match-p "\\`[0-9:.]+\\'" text))
    (let ((seconds 0))
      (dolist (part (split-string text ":"))
        (setq seconds (+ (* 60 seconds) (string-to-number part))))
      (floor seconds))))

(defun ready-player-podcast--format-duration (seconds)
  "Format SECONDS as a clock string."
  (if (>= seconds 3600)
      (format "%d:%02d:%02d"
              (/ seconds 3600) (/ (% seconds 3600) 60) (% seconds 60))
    (format "%d:%02d" (/ seconds 60) (% seconds 60))))

(defun ready-player-podcast--episodes (feed-url)
  "Return podcast episodes from FEED-URL, newest first.
Each episode is a plist with :title, :url, :date, :month, and
:duration (in whole seconds, or nil)."
  (let* ((feed (with-temp-buffer
                 (url-insert-file-contents feed-url)
                 (xml-parse-region (point-min) (point-max))))
         (channel (car (xml-get-children (assq 'rss feed) 'channel)))
         episodes)
    (dolist (item (xml-get-children channel 'item))
      (let ((title (ready-player-podcast--child-text item 'title))
            (enclosure (xml-get-attribute-or-nil
                        (car (xml-get-children item 'enclosure)) 'url))
            (published (ready-player-podcast--child-text item 'pubDate)))
        (when (and title enclosure)
          (push (list :title title
                      :url enclosure
                      :date (ready-player-podcast--date published)
                      :month (ready-player-podcast--month published)
                      :duration (ready-player-podcast--duration-seconds
                                 (ready-player-podcast--child-text
                                  item 'itunes:duration)))
                episodes))))
    (or (nreverse episodes)
        (user-error "No episodes with audio found at %s" feed-url))))

(defun ready-player-podcast--candidate-alist (episodes)
  "Return completion candidates for EPISODES, keyed by unique title."
  (let (candidates)
    (dolist (episode episodes)
      (let ((title (plist-get episode :title)))
        (when (assoc title candidates)
          (setq title (format "%s (%s)"
                              title
                              (or (plist-get episode :date)
                                  (length candidates)))))
        (push (cons title episode) candidates)))
    (nreverse candidates)))

(defun ready-player-podcast--max-duration-width (candidates)
  "Return the width of the widest formatted duration in CANDIDATES."
  (let ((width 0))
    (dolist (candidate candidates width)
      (let ((duration (plist-get (cdr candidate) :duration)))
        (when duration
          (setq width (max width
                           (string-width
                            (ready-player-podcast--format-duration
                             duration)))))))))

(defun ready-player-podcast--annotation (candidate)
  "Annotate episode CANDIDATE with its duration.
Durations are padded to `ready-player-podcast--duration-width', so
the column lines up against the right edge."
  (let* ((episode (cdr (assoc candidate ready-player-podcast--candidates)))
         (duration (plist-get episode :duration)))
    (when duration
      (let* ((text (format (format "%%%ds"
                                   (max ready-player-podcast--duration-width 1))
                           (ready-player-podcast--format-duration duration)))
             (offset (1+ (string-width text))))
        (concat (propertize " " 'display
                            `(space :align-to (- right ,offset)))
                (propertize text 'face 'completions-annotations))))))

(defun ready-player-podcast--group (candidate transform)
  "Group episode CANDIDATE by its publication month.
With TRANSFORM non-nil, return the candidate for display instead."
  (if transform
      candidate
    (plist-get (cdr (assoc candidate ready-player-podcast--candidates))
               :month)))

(defun ready-player-podcast--episode-table (string predicate action)
  "Complete episode titles from the current candidates in feed order.
STRING, PREDICATE, and ACTION are the standard completion-table
arguments."
  (if (eq action 'metadata)
      '(metadata
        (category . ready-player-podcast-episode)
        (display-sort-function . identity)
        (cycle-sort-function . identity)
        (group-function . ready-player-podcast--group)
        (annotation-function . ready-player-podcast--annotation))
    (complete-with-action action ready-player-podcast--candidates
                          string predicate)))

(defun ready-player-podcast--read-episode (podcast feed-url)
  "Choose an episode of PODCAST from FEED-URL."
  (let* ((ready-player-podcast--candidates
          (ready-player-podcast--candidate-alist
           (ready-player-podcast--episodes feed-url)))
         (ready-player-podcast--duration-width
          (ready-player-podcast--max-duration-width
           ready-player-podcast--candidates))
         (title (completing-read (format "%s episode: " podcast)
                                 #'ready-player-podcast--episode-table
                                 nil t)))
    (cdr (assoc title ready-player-podcast--candidates))))

(defun ready-player-podcast--file-name (name)
  "Return NAME as a safe file-name component."
  (string-trim (replace-regexp-in-string "[/\0]" "-" name)))

(defun ready-player-podcast--episode-file (podcast episode)
  "Return the local file for PODCAST's EPISODE.
Episodes live in a subdirectory per podcast and are prefixed with
their publication date, so directory order is chronological."
  (let* ((path (car (split-string
                     (url-filename (url-generic-parse-url
                                    (plist-get episode :url)))
                     "[?#]")))
         (extension (or (file-name-extension path) "mp3"))
         (date (plist-get episode :date))
         (title (plist-get episode :title)))
    (expand-file-name
     (format "%s.%s"
             (ready-player-podcast--file-name
              (if date (concat date " " title) title))
             extension)
     (expand-file-name (ready-player-podcast--file-name podcast)
                       ready-player-podcast-directory))))

(defun ready-player-podcast--download (url file title open)
  "Download episode TITLE from URL to FILE asynchronously.
With OPEN non-nil, play FILE with ready-player (without displaying
the player buffer) once the download finishes."
  (unless (executable-find "curl")
    (user-error "Downloading episodes requires curl"))
  (make-directory (file-name-directory file) t)
  (let* ((tmp (concat file ".part"))
         (process (make-process
                   :name "ready-player-podcast"
                   :buffer (generate-new-buffer " *ready-player-podcast*")
                   :command (list "curl" "--fail" "--location" "--silent"
                                  "--show-error"
                                  "--user-agent" ready-player-podcast-user-agent
                                  "--output" tmp url)
                   :sentinel #'ready-player-podcast--download-sentinel)))
    ;; The file lacks a lexical-binding cookie, so pass state through
    ;; the process plist rather than a closure.
    (process-put process 'ready-player-podcast-file file)
    (process-put process 'ready-player-podcast-tmp tmp)
    (process-put process 'ready-player-podcast-title title)
    (process-put process 'ready-player-podcast-open open)
    (push (cons file process) ready-player-podcast--downloads)
    (message "Downloading %s..." title)))

(defun ready-player-podcast--download-sentinel (process _event)
  "Finish the episode download owned by PROCESS."
  (unless (process-live-p process)
    (let ((file (process-get process 'ready-player-podcast-file))
          (tmp (process-get process 'ready-player-podcast-tmp))
          (title (process-get process 'ready-player-podcast-title))
          (open (process-get process 'ready-player-podcast-open))
          (buffer (process-buffer process)))
      (setq ready-player-podcast--downloads
            (assoc-delete-all file ready-player-podcast--downloads))
      (unwind-protect
          (if (and (eq (process-status process) 'exit)
                   (zerop (process-exit-status process)))
              (progn
                (rename-file tmp file t)
                (message "Downloaded %s" title)
                (when open
                  (find-file-noselect file)))
            (when (file-exists-p tmp)
              (delete-file tmp))
            (message "Download of %s failed%s" title
                     (if (buffer-live-p buffer)
                         (concat ": " (string-trim
                                       (with-current-buffer buffer
                                         (buffer-string))))
                       "")))
        (when (buffer-live-p buffer)
          (kill-buffer buffer))))))

;;;###autoload
(defun ready-player-podcast (&optional download-only)
  "Play an episode of a podcast from `ready-player-podcast-feeds'.
Download the chosen episode into `ready-player-podcast-directory'
when missing (reusing a previous download otherwise) and play it
with ready-player in the background, without displaying the player
buffer.  With a prefix argument DOWNLOAD-ONLY, only download the
episode for later listening."
  (interactive "P")
  (unless ready-player-podcast-feeds
    (user-error "No subscriptions in `ready-player-podcast-feeds'"))
  (let* ((podcast (if (cdr ready-player-podcast-feeds)
                      (completing-read "Podcast: "
                                       ready-player-podcast-feeds nil t)
                    (caar ready-player-podcast-feeds)))
         (episode (ready-player-podcast--read-episode
                   podcast (cdr (assoc podcast ready-player-podcast-feeds))))
         (file (ready-player-podcast--episode-file podcast episode))
         (title (plist-get episode :title)))
    (cond
     ((assoc file ready-player-podcast--downloads)
      (message "Still downloading %s..." title))
     ((file-exists-p file)
      (if download-only
          (message "Already downloaded: %s" (abbreviate-file-name file))
        (find-file-noselect file)))
     (t
      (ready-player-podcast--download (plist-get episode :url) file title
                                      (not download-only))))))

(provide 'ready-player-podcast)
