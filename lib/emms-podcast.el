;;; emms-podcast.el --- Play podcast episodes with EMMS

;; Subscriptions live in `emms-podcast-feeds', an alist mapping a podcast
;; name to its RSS feed URL. `emms-podcast' picks a podcast (skipping the
;; prompt when there is only one), fetches its feed, and offers the
;; episodes newest first, grouped by publication month, with each
;; episode's duration shown against the right edge of the minibuffer. Choosing an episode replaces
;; the current EMMS playlist and plays it; with a prefix argument the
;; episode is added to the end of the playlist instead.
;;
;; `define-emms-source' also provides `emms-play-podcast-episode' and
;; `emms-add-podcast-episode' for non-interactive use. Tracks carry the
;; podcast name and episode title, so playlists render them as
;; `Podcast - Episode' via `emms-info-track-description', and the
;; feed's episode duration as `info-playing-time' so total track time
;; is known before mpv reports it.
;;
;; Episode cover art from the feed is cached in
;; `emms-podcast-cover-directory' and attached to tracks as the
;; `emms-podcast-cover' property. Covers download asynchronously;
;; playlist entries re-render when one arrives, and the display itself
;; is up to `emms-track-description-function' (see settings/emms.el).

(require 'emms)
(require 'subr-x)
(require 'url)
(require 'url-handlers)
(require 'xml)

(defvar url-http-end-of-headers)

(defgroup emms-podcast nil
  "Play podcast episodes with EMMS."
  :group 'emms
  :prefix "emms-podcast-")

(defcustom emms-podcast-feeds nil
  "Podcast subscriptions as an alist of (NAME . RSS-FEED-URL)."
  :group 'emms-podcast
  :type '(alist :key-type (string :tag "Name")
                :value-type (string :tag "Feed URL")))

(defcustom emms-podcast-cover-directory
  (expand-file-name "covers" emms-directory)
  "Directory where episode cover images are cached."
  :group 'emms-podcast
  :type 'directory)

(defvar emms-podcast--candidates nil
  "Completion candidates for the current episode prompt.
An alist of (TITLE . EPISODE), where EPISODE is a plist as returned
by `emms-podcast--episodes'.")

(defvar emms-podcast--duration-width 0
  "Width of the widest formatted duration in the current candidates.
Episode annotations pad durations to this width so the duration
column stays aligned.")

(defun emms-podcast--child-text (node name)
  "Return the trimmed text of NODE's first NAME child, or nil."
  (let ((text (string-trim
               (mapconcat (lambda (child) (if (stringp child) child ""))
                          (xml-node-children
                           (car (xml-get-children node name)))
                          ""))))
    (unless (string-empty-p text)
      text)))

(defun emms-podcast--date (text)
  "Return RSS pubDate TEXT as YYYY-MM-DD, or nil."
  (when text
    (condition-case nil
        (format-time-string "%Y-%m-%d" (date-to-time text))
      (error nil))))

(defun emms-podcast--month (text)
  "Return RSS pubDate TEXT as a month heading like \"July 2026\"."
  (when text
    (condition-case nil
        (format-time-string "%B %Y" (date-to-time text))
      (error nil))))

(defun emms-podcast--duration-seconds (text)
  "Return itunes:duration TEXT (seconds or H:MM:SS) as whole seconds."
  (when (and text (string-match-p "\\`[0-9:.]+\\'" text))
    (let ((seconds 0))
      (dolist (part (split-string text ":"))
        (setq seconds (+ (* 60 seconds) (string-to-number part))))
      (floor seconds))))

(defun emms-podcast--format-duration (seconds)
  "Format SECONDS as a clock string."
  (if (>= seconds 3600)
      (format "%d:%02d:%02d"
              (/ seconds 3600) (/ (% seconds 3600) 60) (% seconds 60))
    (format "%d:%02d" (/ seconds 60) (% seconds 60))))

(defun emms-podcast--episodes (feed-url)
  "Return podcast episodes from FEED-URL, newest first.
Each episode is a plist with :title, :url, :date, :month, :image,
and :duration (in whole seconds, or nil)."
  (let* ((feed (with-temp-buffer
                 (url-insert-file-contents feed-url)
                 (xml-parse-region (point-min) (point-max))))
         (channel (car (xml-get-children (assq 'rss feed) 'channel)))
         (channel-image (xml-get-attribute-or-nil
                         (car (xml-get-children channel 'itunes:image))
                         'href))
         episodes)
    (dolist (item (xml-get-children channel 'item))
      (let ((title (emms-podcast--child-text item 'title))
            (enclosure (xml-get-attribute-or-nil
                        (car (xml-get-children item 'enclosure)) 'url))
            (published (emms-podcast--child-text item 'pubDate)))
        (when (and title enclosure)
          (push (list :title title
                      :url enclosure
                      :date (emms-podcast--date published)
                      :month (emms-podcast--month published)
                      :image (or (xml-get-attribute-or-nil
                                  (car (xml-get-children
                                        item 'itunes:image))
                                  'href)
                                 channel-image)
                      :duration (emms-podcast--duration-seconds
                                 (emms-podcast--child-text
                                  item 'itunes:duration)))
                episodes))))
    (or (nreverse episodes)
        (user-error "No episodes with audio found at %s" feed-url))))

(defun emms-podcast--candidate-alist (episodes)
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

(defun emms-podcast--max-duration-width (candidates)
  "Return the width of the widest formatted duration in CANDIDATES."
  (let ((width 0))
    (dolist (candidate candidates width)
      (let ((duration (plist-get (cdr candidate) :duration)))
        (when duration
          (setq width (max width
                           (string-width
                            (emms-podcast--format-duration duration)))))))))

(defun emms-podcast--annotation (candidate)
  "Annotate episode CANDIDATE with its duration.
Durations are padded to `emms-podcast--duration-width', so the
column lines up against the right edge."
  (let* ((episode (cdr (assoc candidate emms-podcast--candidates)))
         (duration (plist-get episode :duration)))
    (when duration
      (let* ((text (format (format "%%%ds" (max emms-podcast--duration-width 1))
                           (emms-podcast--format-duration duration)))
             (offset (1+ (string-width text))))
        (concat (propertize " " 'display
                            `(space :align-to (- right ,offset)))
                (propertize text 'face 'completions-annotations))))))

(defun emms-podcast--group (candidate transform)
  "Group episode CANDIDATE by its publication month.
With TRANSFORM non-nil, return the candidate for display instead."
  (if transform
      candidate
    (plist-get (cdr (assoc candidate emms-podcast--candidates)) :month)))

(defun emms-podcast--episode-table (string predicate action)
  "Complete episode titles from `emms-podcast--candidates' in feed order."
  (if (eq action 'metadata)
      '(metadata
        (category . emms-podcast-episode)
        (display-sort-function . identity)
        (cycle-sort-function . identity)
        (group-function . emms-podcast--group)
        (annotation-function . emms-podcast--annotation))
    (complete-with-action action emms-podcast--candidates string predicate)))

(defun emms-podcast--read-episode (podcast feed-url)
  "Choose an episode of PODCAST from FEED-URL."
  (let* ((emms-podcast--candidates
          (emms-podcast--candidate-alist (emms-podcast--episodes feed-url)))
         (emms-podcast--duration-width
          (emms-podcast--max-duration-width emms-podcast--candidates))
         (title (completing-read (format "%s episode: " podcast)
                                 #'emms-podcast--episode-table nil t)))
    (cdr (assoc title emms-podcast--candidates))))

(defun emms-podcast--cover-file (url)
  "Return the cache file name for the cover image at URL."
  (expand-file-name (concat (md5 url) ".jpg") emms-podcast-cover-directory))

(defun emms-podcast--cover-retrieved (status file track)
  "Save a retrieved cover to FILE and attach it to TRACK.
STATUS is the response status from `url-retrieve', whose buffer is
current.  Playlist entries showing TRACK are re-rendered."
  (let ((buffer (current-buffer)))
    (unwind-protect
        (unless (plist-get status :error)
          (goto-char (or url-http-end-of-headers (point-min)))
          ;; `url-http-end-of-headers' sits on the newline before the
          ;; body; no image format starts with CR or LF.
          (skip-chars-forward "\r\n")
          (unless (eobp)
            (let ((coding-system-for-write 'no-conversion))
              (write-region (point) (point-max) file nil 'silent))
            (emms-track-set track 'emms-podcast-cover file)
            (emms-playlist-track-updated track)))
      (when (buffer-live-p buffer)
        (kill-buffer buffer)))))

(defun emms-podcast--add-cover (track url)
  "Attach the episode cover at URL to TRACK.
Use the cache when possible; otherwise download asynchronously and
re-render TRACK's playlist entries on arrival."
  (when url
    (let ((file (emms-podcast--cover-file url)))
      (if (file-exists-p file)
          (emms-track-set track 'emms-podcast-cover file)
        (make-directory emms-podcast-cover-directory t)
        (url-retrieve url #'emms-podcast--cover-retrieved
                      (list file track) t t)))))

(define-emms-source podcast-episode (podcast episode)
  "An EMMS source for one podcast EPISODE.
PODCAST is the podcast's name.  EPISODE is a plist as returned by
`emms-podcast--episodes'."
  (let ((track (emms-track 'url (plist-get episode :url))))
    (emms-track-set track 'info-artist podcast)
    (emms-track-set track 'info-title (plist-get episode :title))
    (when (plist-get episode :duration)
      (emms-track-set track 'info-playing-time
                      (plist-get episode :duration)))
    (emms-podcast--add-cover track (plist-get episode :image))
    (emms-playlist-insert-track track)))

;;;###autoload
(defun emms-podcast ()
  "Play an episode of a podcast subscribed to in `emms-podcast-feeds'.
Replace the current EMMS playlist with the chosen episode and play
it.  With a prefix argument, add the episode to the end of the
playlist without interrupting playback instead."
  (interactive)
  (unless emms-podcast-feeds
    (user-error "No subscriptions in `emms-podcast-feeds'"))
  (let* ((podcast (if (cdr emms-podcast-feeds)
                      (completing-read "Podcast: " emms-podcast-feeds nil t)
                    (caar emms-podcast-feeds)))
         (episode (emms-podcast--read-episode
                   podcast (cdr (assoc podcast emms-podcast-feeds)))))
    (emms-play-podcast-episode podcast episode)))

(provide 'emms-podcast)
