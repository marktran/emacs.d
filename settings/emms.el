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
;; The setup stays minimal: no cache, browser, or mode-line display.
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
                                            :height (* 5 (frame-char-height))
                                            :ascent 'center))
                  " " description)
        description)))

  ;; Tick `emms-playing-time' for the menu heading without the mode
  ;; line display that enabling the mode also turns on.
  (emms-playing-time-mode 1)
  (setq emms-playing-time-display-mode nil)

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

  (transient-define-prefix m/emms-menu ()
    "Custom Transient frontend for EMMS."
    :mode-line-format nil ; no divider under the menu
    :refresh-suffixes t
    [:description m/emms-menu-status
     ["Playback"
      ("SPC" "Play/pause" emms-pause)
      ("s" "Stop" emms-stop)
      ("n" "Next track" emms-next)
      ("p" "Previous track" emms-previous)]
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
