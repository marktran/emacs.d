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
;; back/forward, mirroring the old EMMS transient's seek keys. The
;; buffer runs in Evil's emacs state so those keys win over
;; normal-state bindings. The
;; directory is the playlist: n/p walk the files next to the current
;; one, and the associated dired buffer acts as the queue.
;;
;; `SPC m' is a small global prefix mirroring the old EMMS transient:
;; player, play/stop, next/previous, seek, and podcast episodes.
;; ready-player's own `C-c m' global map is disabled in favor of it.
;; While a track plays, the player buffer shows an "[elapsed/total]"
;; clock: a one-second timer polls mpv over ready-player's IPC
;; socket and renders it after the "(playing)" status through an
;; overlay (the buffer is read-only and rebuilt by ready-player, so
;; an overlay leaves its contents alone), skipping the work while
;; the buffer isn't shown in any window.
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

(use-package ready-player
  :ensure t
  :demand t

  :custom
  (ready-player-ask-for-project-sustainability nil) ; no sponsor button
  (ready-player-set-global-bindings nil) ; `SPC m' replaces `C-c m'
  (ready-player-repeat nil)
  (ready-player-open-playback-commands
   '(("mpv" "--audio-display=no" "--input-ipc-server=<<socket>>"
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
        ;; New or ended playback starts out unpaused.
        (unless (eq process m/ready-player--playback-process)
          (setq m/ready-player--paused nil))
        (setq m/ready-player--playback-process process)))
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
    "Render elapsed/total time in the active player buffer."
    (let ((buffer (ready-player--active-buffer t)))
      (when (and (buffer-live-p buffer)
                 (get-buffer-window buffer t))
        ;; Timer functions run with quit inhibited, and these queries
        ;; block in `accept-process-output' awaiting mpv's reply, which
        ;; makes Emacs warn "Blocking call to accept-process-output with
        ;; quit inhibited!!" on every tick. `with-local-quit' re-allows
        ;; quitting for the wait; a quit merely skips one update.
        (let ((position (with-local-quit (ready-player--position)))
              (duration (with-local-quit (ready-player--duration))))
          ;; The socket queries above wait in `accept-process-output',
          ;; which runs timers and sentinels re-entrantly: playback may
          ;; have been stopped (and the clock cleared) meanwhile, so
          ;; re-check before writing a stale time back.
          (when (process-live-p
                 (buffer-local-value 'ready-player--process buffer))
            (with-current-buffer buffer
              (save-excursion
                (goto-char (point-min))
                (when-let* ((match (text-property-search-forward
                                    'playing-status))
                            (end (prop-match-end match)))
                  (unless (overlayp m/ready-player--time-overlay)
                    (setq m/ready-player--time-overlay (make-overlay end end)))
                  (move-overlay m/ready-player--time-overlay end end)
                  (overlay-put
                   m/ready-player--time-overlay 'after-string
                   (when position
                     (propertize
                      (format " [%s%s]"
                              (m/ready-player--format-time position)
                              (if duration
                                  (concat "/" (m/ready-player--format-time
                                               duration))
                                ""))
                      ;; Match the "(playing)" status face.
                      'face `(:foreground ,(face-foreground
                                            'font-lock-comment-face)
                                          :inherit info-title-2))))))))))))

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
              (overlay-put m/ready-player--time-overlay
                           'after-string nil)))))))

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

  (defun m/ready-player--format-time (seconds)
    "Format SECONDS as a clock string."
    (setq seconds (floor seconds))
    (if (>= seconds 3600)
        (format "%d:%02d:%02d"
                (/ seconds 3600) (/ (% seconds 3600) 60) (% seconds 60))
      (format "%d:%02d" (/ seconds 60) (% seconds 60))))

  ;; The metadata block repeats the container format ("MP2/3 (MPEG
  ;; audio layer 2/3)" and the like) on every file; drop that row.
  ;; There's no customization for it, so filter the row list.
  (defun m/ready-player--drop-format-row (rows)
    "Drop the Format row from metadata ROWS."
    (seq-remove (lambda (row) (equal (alist-get 'label row) "Format:"))
                rows))

  (advice-add 'ready-player--make-metadata-core-rows :filter-return
              #'m/ready-player--drop-format-row)

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
