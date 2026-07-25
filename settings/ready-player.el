;;; ready-player.el --- Music and podcasts with ready-player

;; ready-player turns media files into playable buffers: enabling
;; `ready-player-mode' makes find-file and dired open audio/video in
;; `ready-player-major-mode', which shows the file's metadata and
;; cover art (via ffprobe/ffmpegthumbnailer) with its own playback
;; keys (SPC play/stop, n/p next/previous, f/b seek, r repeat,
;; s shuffle, d dired playlist). Two amendments: `q' buries the
;; buffer, leaving playback running (the default `ready-player-quit'
;; kills the buffer, and this config's quit-window advice would too),
;; and the arrow keys seek — left/right 10s back/forward, down/up 1m
;; back/forward, mirroring the old EMMS transient's seek keys.
;; Seeking flashes ready-player's progress bar in the echo area;
;; advice sizes that bar to the echo area's true width (see
;; `m/ready-player--fit-progress-bar'). The buffer runs in Evil's
;; emacs state so those keys win over normal-state bindings. The
;; directory is the playlist: n/p walk the files next to the current
;; one, and the associated dired buffer acts as the queue.
;;
;; `SPC m' is a small global prefix mirroring the old EMMS transient:
;; player, play/stop, next/previous, seek, podcast episodes, and live
;; radio.
;; ready-player's own `C-c m' global map is disabled in favor of it.
;; The player buffer's metadata block gets a "Position:" row (the
;; conventional name for elapsed playback time — MPRIS and mpv call
;; it the same) above ready-player's own "Duration:" row. Its value
;; is a "--:--" placeholder; while a track plays, a one-second timer
;; polls mpv over ready-player's IPC socket and covers the
;; placeholder with the current position through an overlay's
;; display property (the buffer is read-only and rebuilt by
;; ready-player, so an overlay leaves its contents alone), skipping
;; the work while the buffer isn't shown in any window.
;;
;; Playback uses mpv with volume pinned at 100% — the same rationale
;; as the EMMS setup this replaces: loudness comes from the system
;; audio controls, and watch-later state (mpv.conf saves position on
;; quit) must not restore an old volume or mute. The
;; `--input-ipc-server' socket is ready-player's own channel for
;; seeking.
;;
;; `SPC m e' prompts for an episode of a podcast subscribed to in
;; `ready-player-podcast-feeds' (see lib/ready-player-podcast.el),
;; newest first with month groups and durations. ready-player only
;; plays local files, so the episode is downloaded (or reused from
;; the download cache under no-littering's var directory, which
;; recentf already excludes) and autoplayed in the background — the
;; player view stays hidden until `SPC m m' brings it up. `C-u SPC
;; m e' downloads without playing.
;;
;; `SPC m r' picks a live station from `ready-player-radio-stations'
;; (see lib/ready-player-radio.el) and plays it in the background the
;; same way. The BBC networks stream 320kbps AAC from worldwide HLS
;; pools that need neither a VPN nor a sign-in: the BBC's
;; geo-blocking covers television and some on-demand rights, not the
;; radio simulcasts. Pointing at a station's master playlist leaves
;; the choice of bitrate to mpv, which takes the highest.
;;
;; A stream needs two concessions in a player built for files.
;; Stations get their own mpv command: no watch-later state (mpv.conf
;; saves position on quit) for a stream with no position to resume,
;; and no sibling scanning (mpv.conf's `autocreate-playlist'), which
;; would otherwise queue up the neighboring stubs. And since ffprobe
;; reads no tags off a stub file, advice passes the station name in as
;; the file's title, which both heads the buffer with "BBC Radio 4"
;; instead of "BBC Radio 4.radio" and gets the metadata block — where
;; the Position clock lives — drawn at all.
;;
;; Playback stops at the end of the file: the repeat default (t)
;; wraps around the directory, which for a podcast means replaying
;; episodes forever; the old EMMS setup also defaulted to no repeat.
;; `r' in the player buffer still cycles repeat modes.
;;
;; The only mode-line presence is a right-aligned play icon while a
;; track is playing (see init.el's `mode-line-format', shared with
;; the old EMMS setup): ready-player has no playback hooks, but every
;; start/stop funnels through its buffer-status refresh, so advice
;; there records the playback process and refreshes mode lines;
;; `m/ready-player-playing-p' then just checks that process, which
;; also self-corrects if the player dies without a refresh. Pausing
;; hides the icon too (tracked by advice on the pause toggle); the
;; in-buffer clock keeps showing the frozen position meanwhile.

;; Declared before ready-player: the stub extension has to be in
;; `ready-player-supported-audio' before `ready-player-mode' builds
;; `auto-mode-alist' from it, and the station-titling advice calls in.
(use-package ready-player-radio
  :ensure nil
  :load-path "lib"
  :demand t

  :custom
  (ready-player-radio-directory
   (no-littering-expand-var-file-name "ready-player/radio"))
  ;; Pool IDs rotate every few years (pool_904 answers 410 Gone now),
  ;; which is why most BBC stream URLs found online are dead. When a
  ;; station stops resolving, re-read the current URLs from the
  ;; community stream directory:
  ;;   curl -s 'https://de1.api.radio-browser.info/json/stations/search?name=BBC' \
  ;;     | jq -r '.[].url_resolved'
  (ready-player-radio-stations
   (let ((bbc (lambda (station pool)
                ;; The master playlist, leaving mpv to pick its
                ;; highest bitrate (320kbps AAC).
                (format (concat "https://as-hls-ww-live.akamaized.net"
                                "/%s/live/ww/%s/%s.isml/%s.m3u8")
                        pool station station station))))
     `(("BBC Radio 4"
        . ,(funcall bbc "bbc_radio_fourfm" "pool_55057080"))
       ("BBC Radio 4 Extra"
        . ,(funcall bbc "bbc_radio_four_extra" "pool_26173715"))
       ("BBC Radio 3"
        . ,(funcall bbc "bbc_radio_three" "pool_23461179"))
       ("BBC Radio 6 Music"
        . ,(funcall bbc "bbc_6music" "pool_81827798"))
       ("BBC World Service"
        . ,(funcall bbc "bbc_world_service" "pool_87948813")))))

  :general
  ("SPC m r" '(ready-player-radio :which-key "Radio")))

(use-package ready-player
  :ensure t
  :demand t

  :custom
  (ready-player-ask-for-project-sustainability nil) ; no sponsor button
  (ready-player-set-global-bindings nil) ; `SPC m' replaces `C-c m'
  (ready-player-repeat nil)
  (ready-player-open-playback-commands
   ;; An extension list as the first element scopes a command to it:
   ;; live streams (see lib/ready-player-radio.el) take the first
   ;; entry, everything else the second.
   '((("radio") "mpv" "--audio-display=no" "--input-ipc-server=<<socket>>"
      "--volume=100"
      "--autocreate-playlist=no"
      "--no-resume-playback"
      "--save-position-on-quit=no")
     ("mpv" "--audio-display=no" "--input-ipc-server=<<socket>>"
      "--volume=100"
      "--watch-later-options-remove=volume"
      "--watch-later-options-remove=mute")))

  :general
  ("SPC m" '(:ignore t :which-key "Music")
   "SPC m m" '(ready-player-view-player :which-key "Player")
   "SPC m SPC" '(m/ready-player-toggle-play-stop :which-key "Play/stop")
   "SPC m n" '(ready-player-next :which-key "Next track")
   "SPC m p" '(ready-player-previous :which-key "Previous track")
   "SPC m f" '(ready-player-seek-forward :which-key "Seek forward")
   "SPC m b" '(ready-player-seek-backward :which-key "Seek backward"))

  :config
  ;; The player buffer's single-key controls beat normal state.
  (evil-set-initial-state 'ready-player-major-mode 'emacs)

  (defvar m/ready-player--playback-process nil
    "The most recent ready-player playback process.")

  (defvar m/ready-player--paused nil
    "Non-nil while the tracked playback process is paused.")

  (defun m/ready-player--session-live-p ()
    "Return non-nil while a playback process is alive, even paused."
    (process-live-p m/ready-player--playback-process))

  (defun m/ready-player-playing-p ()
    "Return non-nil while ready-player is actively playing.
Paused playback doesn't count, so the mode-line icon (see init.el)
disappears while paused, as it did under EMMS."
    (and (m/ready-player--session-live-p)
         (not m/ready-player--paused)))

  ;; Pause and unpause funnel through `ready-player--toggle-pause';
  ;; record the state mpv ends up in.
  (defun m/ready-player--track-pause (&rest _)
    "Record the paused state and refresh mode lines."
    (setq m/ready-player--paused (ready-player--paused-p))
    (force-mode-line-update t))

  (advice-add 'ready-player--toggle-pause :after
              #'m/ready-player--track-pause)

  ;; Keep the play icon in `mode-line-format' (see init.el) in sync
  ;; with playback state.
  (defun m/ready-player-mode-line-refresh (buffer &rest _)
    "Track BUFFER's playback process and refresh all mode lines.
Also start the playing-time updates while a track plays, and clear
the clock when playback stops."
    (when (buffer-live-p buffer)
      (let ((process (buffer-local-value 'ready-player--process buffer)))
        (cond
         ;; New playback starts out unpaused.
         ((process-live-p process)
          (unless (eq process m/ready-player--playback-process)
            (setq m/ready-player--paused nil))
          (setq m/ready-player--playback-process process))
         ;; BUFFER has no live playback. Only treat that as a stop
         ;; when nothing newer is playing: replacing playback (say,
         ;; picking an episode while another plays) starts the new
         ;; process first, and the old process's sentinel then
         ;; refreshes its old buffer with no process — that stale
         ;; refresh must not clobber the live one.
         ((not (m/ready-player--session-live-p))
          (setq m/ready-player--playback-process nil
                m/ready-player--paused nil)))))
    (if (m/ready-player--session-live-p)
        (unless m/ready-player--time-timer
          (setq m/ready-player--time-timer
                (run-at-time 0 1 #'m/ready-player--time-tick)))
      (m/ready-player--time-tick))
    (force-mode-line-update t))

  ;; Playing time in the player buffer, after the "(playing)" status.
  (defvar m/ready-player--time-timer nil
    "Timer updating the player buffer's playing time.")

  (defvar-local m/ready-player--time-overlay nil
    "Overlay showing the playing time in a player buffer.")

  (defun m/ready-player--render-time ()
    "Render the playback position in the active player buffer.
Covers the Position row's placeholder (see
`m/ready-player--add-position-row') with the current time."
    (let ((buffer (ready-player--active-buffer t)))
      (when (and (buffer-live-p buffer)
                 (get-buffer-window buffer t))
        ;; Timer functions run with quit inhibited, and this query
        ;; blocks in `accept-process-output' awaiting mpv's reply, which
        ;; makes Emacs warn "Blocking call to accept-process-output with
        ;; quit inhibited!!" on every tick. `with-local-quit' re-allows
        ;; quitting for the wait; a quit merely skips one update.
        (let ((position (with-local-quit (ready-player--position))))
          ;; The socket query above waits in `accept-process-output',
          ;; which runs timers and sentinels re-entrantly: playback may
          ;; have been stopped (and the clock cleared) meanwhile, so
          ;; re-check before writing a stale time back.
          (when (and position
                     (process-live-p
                      (buffer-local-value 'ready-player--process buffer)))
            (with-current-buffer buffer
              (save-excursion
                (goto-char (point-min))
                (when-let* ((match (text-property-search-forward
                                    'm/ready-player-position-field))
                            (start (prop-match-beginning match))
                            (end (prop-match-end match)))
                  (unless (overlayp m/ready-player--time-overlay)
                    (setq m/ready-player--time-overlay
                          (make-overlay start end)))
                  (move-overlay m/ready-player--time-overlay start end)
                  (overlay-put m/ready-player--time-overlay 'display
                               (m/ready-player--format-time
                                position))))))))))

  (defun m/ready-player--time-tick ()
    "Update the playing time, ending the updates when playback stops."
    (if (m/ready-player--session-live-p)
        (m/ready-player--render-time)
      (when m/ready-player--time-timer
        (cancel-timer m/ready-player--time-timer)
        (setq m/ready-player--time-timer nil))
      (let ((buffer (ready-player--active-buffer t)))
        (when (buffer-live-p buffer)
          (with-current-buffer buffer
            (when (overlayp m/ready-player--time-overlay)
              ;; Uncover the placeholder.
              (overlay-put m/ready-player--time-overlay 'display nil)))))))

  (advice-add 'ready-player--refresh-buffer-status :after
              #'m/ready-player-mode-line-refresh)

  ;; `ready-player--update-buffer' (pause toggles, metadata/thumbnail
  ;; arrivals) erases and rebuilds the buffer, collapsing the clock
  ;; overlay to the buffer start where its stale text would flash;
  ;; drop the overlay and re-render it in place right away.
  (defun m/ready-player--reset-time-overlay (buffer &rest _)
    "Re-create the clock overlay after BUFFER is rebuilt."
    (when (buffer-live-p buffer)
      (with-current-buffer buffer
        (when (overlayp m/ready-player--time-overlay)
          (delete-overlay m/ready-player--time-overlay)
          (setq m/ready-player--time-overlay nil))))
    (m/ready-player--time-tick))

  (advice-add 'ready-player--update-buffer :after
              #'m/ready-player--reset-time-overlay)

  ;; A station stub holds a URL, so ffprobe finds no tags on it: the
  ;; buffer would head itself "BBC Radio 4.radio" and, having no
  ;; metadata at all, would skip the metadata block that carries the
  ;; Position clock. Pass the station name in as the file's title,
  ;; which the heading prefers over the file name (and which the block
  ;; below it drops as a duplicate).
  (defun m/ready-player--name-station (args)
    "Title a station stub after its station in ARGS."
    (if-let* ((station (ready-player-radio-station-name (nth 1 args)))
              ;; METADATA is the 8th argument, and optional; pad up to it.
              (padded (append args
                              (make-list (max 0 (- 8 (length args))) nil))))
        (append (seq-take padded 7)
                ;; Shaped like the ffprobe JSON ready-player reads.
                (list `((format . ((tags . ((title . ,station)))))))
                (seq-drop padded 8))
      args))

  (advice-add 'ready-player--update-buffer :filter-args
              #'m/ready-player--name-station)

  (defun m/ready-player--format-time (seconds)
    "Format SECONDS as a clock string."
    (setq seconds (floor seconds))
    (if (>= seconds 3600)
        (format "%d:%02d:%02d"
                (/ seconds 3600) (/ (% seconds 3600) 60) (% seconds 60))
      (format "%d:%02d" (/ seconds 60) (% seconds 60))))

  ;; The metadata block repeats the container format ("MP2/3 (MPEG
  ;; audio layer 2/3)" and the like) on every file; drop that row.
  ;; There's no customization for the rows, so filter the row list,
  ;; also adding the Position row above its natural companion,
  ;; Duration.
  (defun m/ready-player--adjust-core-rows (rows)
    "Drop the Format row from metadata ROWS and add a Position row.
The Position value is a placeholder whose text property anchors the
playback clock; while a track plays, an overlay covers it with the
current position (see `m/ready-player--render-time')."
    (let* ((rows (seq-remove (lambda (row)
                               (equal (alist-get 'label row) "Format:"))
                             rows))
           (index (or (seq-position rows "Duration:"
                                    (lambda (row label)
                                      (equal (alist-get 'label row) label)))
                      (length rows))))
      (append (seq-take rows index)
              (list (list (cons 'label "Position:")
                          (cons 'value (propertize
                                        "--:--"
                                        'm/ready-player-position-field t))))
              (seq-drop rows index))))

  (advice-add 'ready-player--make-metadata-core-rows :filter-return
              #'m/ready-player--adjust-core-rows)

  (defun m/ready-player-toggle-play-stop ()
    "Toggle play/pause of media without any echo-area chatter.
`ready-player-toggle-play-stop' reports a (wrongly computed) paused
state and pops the clipped SVG info card on unpause; silence both —
the mode-line icon already shows the playback state."
    (interactive)
    (cl-letf (((symbol-function 'ready-player--message) #'ignore)
              ((symbol-function 'ready-player-show-info) #'ignore))
      (ready-player-toggle-play-stop)))

  (defun m/ready-player-bury-buffer ()
    "Bury the player buffer, leaving playback running."
    (interactive)
    (bury-buffer))

  ;; Seeking flashes a time progress bar in the echo area.
  ;; ready-player builds it exactly `frame-width' columns wide, but
  ;; the echo area's usable width is a hair narrower (the fringe eats
  ;; into it, and `ready-player--message' prepends a direction mark
  ;; that displays as a thin space), so the bar's last character — the
  ;; final digit of the track duration — wrapped onto a second
  ;; echo-area line as a stray digit in the lower-left corner. Build
  ;; the bar against the echo area's real width instead, sparing one
  ;; column for the direction mark.
  (defun m/ready-player--fit-progress-bar (make-bar &rest args)
    "Call MAKE-BAR with `frame-width' shrunk to the echo area's width."
    (cl-letf (((symbol-function 'frame-width)
               (lambda (&optional _frame)
                 (1- (window-max-chars-per-line (minibuffer-window))))))
      (apply make-bar args)))

  (advice-add 'ready-player--make-time-progress-bar :around
              #'m/ready-player--fit-progress-bar)

  (defun m/ready-player-seek-forward-10s ()
    "Seek 10 seconds forward in the current track."
    (interactive)
    (ready-player-seek-forward 10))

  (defun m/ready-player-seek-backward-10s ()
    "Seek 10 seconds backward in the current track."
    (interactive)
    (ready-player-seek-backward 10))

  (defun m/ready-player-seek-forward-1m ()
    "Seek one minute forward in the current track."
    (interactive)
    (ready-player-seek-forward 60))

  (defun m/ready-player-seek-backward-1m ()
    "Seek one minute backward in the current track."
    (interactive)
    (ready-player-seek-backward 60))

  ;; `q' hides rather than kills, and the arrow keys seek.
  (define-key ready-player-major-mode-map (kbd "q")
              #'m/ready-player-bury-buffer)
  (define-key ready-player-major-mode-map (kbd "<right>")
              #'m/ready-player-seek-forward-10s)
  (define-key ready-player-major-mode-map (kbd "<left>")
              #'m/ready-player-seek-backward-10s)
  (define-key ready-player-major-mode-map (kbd "<up>")
              #'m/ready-player-seek-forward-1m)
  (define-key ready-player-major-mode-map (kbd "<down>")
              #'m/ready-player-seek-backward-1m)

  ;; Claim the station stubs before `ready-player-mode' builds
  ;; `auto-mode-alist' from this list.
  (add-to-list 'ready-player-supported-audio ready-player-radio-extension)

  (ready-player-mode 1))

(use-package ready-player-podcast
  :ensure nil
  :load-path "lib"
  :commands ready-player-podcast

  :general
  ("SPC m e" '(ready-player-podcast :which-key "Episodes"))

  :custom
  (ready-player-podcast-directory
   (no-littering-expand-var-file-name "ready-player/podcasts"))
  (ready-player-podcast-feeds
   '(("Midnight Radio" . "https://feeds.buzzsprout.com/2541955.rss")
     ("Shipping Forecast" . "https://shippingforecast.uk/feed.xml")
     ("Marfa Public Radio Puts You to Sleep"
      . "https://www.marfapublicradio.org/podcast/marfa-public-radio-puts-you-to-sleep/rss.xml"))))
