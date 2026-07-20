;;; emms.el --- Music and podcasts with EMMS

;; EMMS plays audio with mpv (installed on both platforms outside Nix).
;; `SPC m' opens `m/emms-menu', a custom Transient frontend and the
;; single entry point: the heading shows the playback state with
;; elapsed and total time, and the groups cover playback, repeatable
;; seek keys, playlist commands, podcast episodes, and repeat/shuffle
;; toggles with checkbox state. Playlist buffer keys come from
;; evil-collection (see settings/evil.el). Playback volume is pinned
;; at 100% — mpv starts with --volume=100 and won't restore saved
;; volume or mute state from watch-later files — so loudness is
;; adjusted with the system audio controls instead.
;;
;; Next/previous only act when the playlist actually has a track in
;; that direction (respecting `emms-repeat-playlist' wrap-around):
;; plain `emms-next'/`emms-previous' stop playback before noticing
;; there is nothing to select, which kills the current track. The
;; menu dims their labels when they don't apply; the keys stay
;; invokable (Transient's `:inapt-if*' would intercept them with a
;; cryptic "Inapt command" warning) and just report that there is
;; nothing to play.
;;
;; Playlists persist across sessions: emms-history saves them (with
;; the selected track and repeat settings) on exit and restores them
;; when EMMS first loads.
;;
;; The playlist buffer holds the playlist itself, so killing it
;; discards the queue — and this config's `quit-window' advice
;; (lisp/quit-window.el) turns every quit into a kill. `q' in the
;; playlist therefore buries the buffer instead, killing a playlist
;; that still has tracks asks for confirmation first, and a confirmed
;; kill also stops playback so the menu reports a clean stop rather
;; than an unresolvable current track.
;;
;; `e' in the menu prompts for an episode of a podcast subscribed to in
;; `emms-podcast-feeds' (see lib/emms-podcast.el), newest first with
;; date and duration. `RET' replaces the playlist with the episode and
;; streams it through mpv; with a prefix argument (`C-u e') it is
;; enqueued at the end instead. Streaming avoids the 403 that
;; Buzzsprout's CDN returns for curl's User-Agent — mpv's is accepted.
;;
;; Playlist entries for podcast episodes show the episode's cover art
;; inline at three lines tall (lib/emms-podcast.el caches the images and
;; re-renders entries when a download finishes); the menu heading
;; stays text-only.
;;
;; The setup stays minimal: no cache, browser, or EMMS mode-line
;; track display. The only mode-line presence is a right-aligned play
;; icon while a track is actively playing (nothing when paused or
;; stopped): the icon itself lives in init.el's `mode-line-format',
;; and the player hooks below refresh mode lines on state changes.
;; `emms-playing-time-mode' runs with its mode line display disabled so
;; the menu heading can show elapsed time; mpv reports each track's
;; duration for the total (`emms-player-mpv-update-duration').

(use-package emms
  :ensure t

  :preface
  (defun m/emms-playlist ()
    "Switch to the EMMS playlist buffer, creating it when missing."
    (interactive)
    (require 'emms-playlist-mode)
    (unless (buffer-live-p emms-playlist-buffer)
      (setq emms-playlist-buffer (emms-playlist-new)))
    (emms-playlist-mode-go))

  :custom
  (emms-player-list '(emms-player-mpv))
  ;; Defaults plus a volume pinned at 100%: system audio controls
  ;; handle loudness, and watch-later state (mpv.conf saves position
  ;; on quit) must not restore an old volume or mute.
  (emms-player-mpv-parameters '("--quiet" "--really-quiet"
                                "--no-audio-display" "--volume=100"
                                "--watch-later-options-remove=volume"
                                "--watch-later-options-remove=mute"))
  (emms-track-description-function #'m/emms-track-description)

  :general
  ("SPC m" '(m/emms-menu :which-key "Music"))
  (:keymaps 'emms-playlist-mode-map
   :states 'normal
   "q" 'emms-playlist-mode-bury-buffer)

  :config
  (require 'emms-setup)
  (emms-minimalistic)
  (require 'emms-info)
  (require 'emms-playing-time)
  (require 'transient)

  (defun m/emms-track-description (track)
    "Describe TRACK, prefixed with its podcast cover when available."
    (let ((description (emms-info-track-description track))
          (cover (emms-track-get track 'emms-podcast-cover)))
      (if (and cover (display-images-p) (file-exists-p cover))
          (concat (propertize " " 'display
                              (create-image cover nil nil
                                            :height (* 6 (frame-char-height))
                                            :ascent 'center))
                  " " description)
        description)))

  ;; Tick `emms-playing-time' for the menu heading without the mode
  ;; line display that enabling the mode also turns on.
  (emms-playing-time-mode 1)
  (setq emms-playing-time-display-mode nil)

  ;; Keep the play icon in `mode-line-format' (see init.el) in sync
  ;; with playback state.
  (defun m/emms-mode-line-refresh ()
    "Refresh all mode lines so the playback indicator stays current."
    (force-mode-line-update t))

  (dolist (hook '(emms-player-started-hook
                  emms-player-stopped-hook
                  emms-player-finished-hook
                  emms-player-paused-hook))
    (add-hook hook #'m/emms-mode-line-refresh))

  ;; `emms-player-mpv-update-duration' (default t) only handles mpv's
  ;; duration events; mpv only emits them when the property is
  ;; observed, which EMMS ties to `emms-player-mpv-update-metadata'.
  ;; Observe the property directly instead — enabling metadata updates
  ;; would also overwrite podcast tracks' titles with the files' tags.
  (defun m/emms-player-mpv-observe-duration ()
    "Ask mpv to report track durations."
    (emms-player-mpv-observe-property 'duration))
  (add-hook 'emms-player-mpv-event-connect-hook
            #'m/emms-player-mpv-observe-duration)

  ;; The playlist buffer is the playlist: killing it discards the
  ;; queue, so confirm first and stop playback on a confirmed kill.
  (defun m/emms-playlist-kill-buffer-query ()
    "Confirm killing the current EMMS playlist while it has tracks."
    (or (not (and emms-playlist-buffer-p
                  (eq (current-buffer) emms-playlist-buffer)
                  (> (buffer-size) 0)))
        (yes-or-no-p "Killing this buffer clears the EMMS playlist; continue? ")))

  (defun m/emms-playlist-stop-on-kill ()
    "Stop playback when the current EMMS playlist buffer is killed."
    (when (and emms-playlist-buffer-p
               (eq (current-buffer) emms-playlist-buffer)
               emms-player-playing-p)
      (emms-stop)))

  (add-hook 'kill-buffer-query-functions #'m/emms-playlist-kill-buffer-query)
  (add-hook 'kill-buffer-hook #'m/emms-playlist-stop-on-kill)

  (defun m/emms-menu--format-time (seconds)
    "Format SECONDS as a clock string."
    (setq seconds (floor seconds))
    (if (>= seconds 3600)
        (format "%d:%02d:%02d"
                (/ seconds 3600) (/ (% seconds 3600) 60) (% seconds 60))
      (format "%d:%02d" (/ seconds 60) (% seconds 60))))

  (defun m/emms-menu-status ()
    "Describe the EMMS playback state for the menu heading.
While stopped, show the still-selected track, e.g. the one restored
by emms-history. Ends with a newline so a blank line separates the
heading from the menu columns."
    (let* ((track (emms-playlist-current-selected-track))
           (description (and track (emms-info-track-description track)))
           (total (and track (emms-track-get track 'info-playing-time))))
      (concat
       (cond
        ((and description emms-player-playing-p)
         (format "EMMS%s: %s  [%s]"
                 (if emms-player-paused-p " (paused)" "")
                 description
                 (concat (m/emms-menu--format-time emms-playing-time)
                         (and total
                              (concat "/"
                                      (m/emms-menu--format-time total))))))
        (description
         (format "EMMS (stopped): %s" description))
        (emms-player-playing-p "EMMS: ?")
        (t "EMMS: stopped"))
       "\n")))

  ;; `emms-next'/`emms-previous' stop the current player *before*
  ;; discovering the playlist has no track in that direction, so at
  ;; the playlist edge they kill playback and lose the current
  ;; track's state. Probe first, without moving the selection.
  (defun m/emms--selectable-track-p (move wrap edge)
    "Return non-nil when the current playlist can select another track.
Mirrors the movement of `emms-playlist-select-next' and
`emms-playlist-select-previous' without moving the selection: MOVE
is the movement function, WRAP the fallback used when
`emms-repeat-playlist' wraps around, and EDGE where to start when
no track is selected."
    (with-current-emms-playlist
      (save-excursion
        (goto-char (or (and emms-playlist-selected-marker
                            (marker-position emms-playlist-selected-marker))
                       (funcall edge)))
        (ignore-errors
          (if emms-repeat-playlist
              (condition-case nil
                  (funcall move)
                (error (funcall wrap)))
            (funcall move))
          t))))

  (defun m/emms-next-track-p ()
    "Return non-nil when the playlist has a next track to select."
    (m/emms--selectable-track-p
     #'emms-playlist-next #'emms-playlist-first #'point-min))

  (defun m/emms-previous-track-p ()
    "Return non-nil when the playlist has a previous track to select."
    (m/emms--selectable-track-p
     #'emms-playlist-previous #'emms-playlist-last #'point-max))

  (defun m/emms-next ()
    "Play the next track, only when the playlist has one.
Unlike `emms-next', leave the current track alone at the end of
the playlist."
    (interactive)
    (if (m/emms-next-track-p)
        (emms-next)
      (message "No next track in playlist")))

  (defun m/emms-previous ()
    "Play the previous track, only when the playlist has one.
Unlike `emms-previous', leave the current track alone at the start
of the playlist."
    (interactive)
    (if (m/emms-previous-track-p)
        (emms-previous)
      (message "No previous track in playlist")))

  (defun m/emms-seek-backward-1m ()
    "Seek one minute backward in the current track."
    (interactive)
    (emms-seek -60))

  (defun m/emms-seek-forward-1m ()
    "Seek one minute forward in the current track."
    (interactive)
    (emms-seek 60))

  (defun m/emms-playlist-clear ()
    "Stop playback and clear the current playlist."
    (interactive)
    (emms-stop)
    (emms-playlist-current-clear))

  (defun m/emms-toggle-repeat-track ()
    "Toggle repeating the current track.
`emms-repeat-track' is buffer-local, and EMMS checks it in the
playlist buffer when a track ends, so toggle it there."
    (interactive)
    (with-current-emms-playlist
      (emms-toggle-repeat-track)))

  (defun m/emms-menu--checkbox (label on)
    "Return LABEL with a checkbox reflecting ON."
    (format "%s %s" label (if on "[x]" "[ ]")))

  (defun m/emms-menu-repeat-track-description ()
    "Describe the repeat-track toggle with its state."
    (m/emms-menu--checkbox "Repeat track"
                           (with-current-emms-playlist emms-repeat-track)))

  (defun m/emms-menu-repeat-playlist-description ()
    "Describe the repeat-playlist toggle with its state."
    (m/emms-menu--checkbox "Repeat playlist" emms-repeat-playlist))

  (defun m/emms-menu-shuffle-description ()
    "Describe the shuffle toggle with its state."
    (m/emms-menu--checkbox "Shuffle" emms-random-playlist))

  (defun m/emms-menu--maybe-dim (label available)
    "Return LABEL, dimmed like an inapt suffix unless AVAILABLE."
    (if available
        label
      (propertize label 'face 'transient-inapt-suffix)))

  (defun m/emms-menu-next-description ()
    "Describe the next-track entry, dimmed when there is no next track."
    (m/emms-menu--maybe-dim "Next track" (m/emms-next-track-p)))

  (defun m/emms-menu-previous-description ()
    "Describe the previous-track entry, dimmed when there is none."
    (m/emms-menu--maybe-dim "Previous track" (m/emms-previous-track-p)))

  (transient-define-prefix m/emms-menu ()
    "Custom Transient frontend for EMMS."
    :mode-line-format nil ; no divider under the menu
    :refresh-suffixes t
    [:description m/emms-menu-status
     ["Playback"
      ("SPC" "Play/pause" emms-pause)
      ("s" "Stop" emms-stop)
      ("n" m/emms-next :description m/emms-menu-next-description)
      ("p" m/emms-previous :description m/emms-menu-previous-description)]
     ["Seek"
      ("b" "Back 10s" emms-seek-backward :transient t)
      ("f" "Forward 10s" emms-seek-forward :transient t)
      ("B" "Back 1m" m/emms-seek-backward-1m :transient t)
      ("F" "Forward 1m" m/emms-seek-forward-1m :transient t)]]
    [["Playlist"
      ("l" "List" m/emms-playlist)
      ("c" "Clear" m/emms-playlist-clear)]
     ["Podcast"
      ("e" "Episodes" emms-podcast)]
     ["Toggles"
      ("r" m/emms-toggle-repeat-track
       :description m/emms-menu-repeat-track-description :transient t)
      ("R" emms-toggle-repeat-playlist
       :description m/emms-menu-repeat-playlist-description :transient t)
      ("S" emms-toggle-random-playlist
       :description m/emms-menu-shuffle-description :transient t)]])

  ;; Persist playlists across sessions. Requiring emms-history hooks
  ;; saving into `kill-emacs-hook'; loading restores the playlists
  ;; saved by the previous session. Restore last: inserting restored
  ;; tracks renders descriptions through `m/emms-track-description',
  ;; so everything above must already be defined.
  (require 'emms-history)
  (make-directory emms-directory t)
  (emms-history-load))

(use-package emms-podcast
  :ensure nil
  :load-path "lib"
  :commands emms-podcast

  :custom
  (emms-podcast-feeds
   '(("Midnight Radio" . "https://feeds.buzzsprout.com/2541955.rss"))))
