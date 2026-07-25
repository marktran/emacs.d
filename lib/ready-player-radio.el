;;; ready-player-radio.el --- Play live radio stations with ready-player

;; Stations live in `ready-player-radio-stations', an alist mapping a station
;; name to the URL of its stream. `ready-player-radio' picks a station
;; (skipping the prompt when there is only one) and plays it through
;; ready-player in the background — the player buffer is created but not
;; displayed; `ready-player-view-player' brings it up.
;;
;; ready-player plays files, not URLs: it hands `buffer-file-name' to mpv. So
;; each station gets a one-line stub file whose only content is its stream URL,
;; and mpv — which recognizes the `#EXTM3U' header whatever the file is called —
;; follows that URL instead of reading the file as audio. The stubs are
;; generated, so `ready-player-radio-stations' stays the single source of truth:
;; every call rewrites them and removes the ones whose station is gone.
;;
;; The stubs deliberately do not use the .m3u extension, even though that is
;; what their content is: ready-player treats .m3u as a playlist of local files
;; and builds a `dired' playlist from the ones that exist, which for a URL is
;; none of them ("No media found", raised while the major mode is still setting
;; up). Hence `ready-player-radio-extension', a made-up extension added to
;; `ready-player-supported-audio' (see settings/ready-player.el) so that
;; ready-player claims these files while leaving its .m3u handling alone.
;;
;; Because all stations are written out on every call, the stub directory is a
;; playlist of every subscribed station: `n' and `p' in the player buffer walk
;; from station to station, and the associated `dired' buffer acts as a dial.
;; Stations sort alphabetically there, not in `ready-player-radio-stations'
;; order.
;;
;; ffprobe reads no tags off a stub, so settings/ready-player.el hands
;; ready-player the station name from `ready-player-radio-station-name' as the
;; file's title: the player buffer then heads itself "BBC Radio 4" rather than
;; "BBC Radio 4.radio", and its metadata block — which ready-player only draws
;; for a file with metadata, and which holds the playback clock — renders at
;; all.
;;
;; A live stream has no length to speak of: mpv reports a window that grows as
;; it buffers (19s, then 25s, then minutes), so nothing useful can be seeked
;; to beyond what is still cached, and there is no position worth resuming
;; later. The clock counts up from when playback started.

(require 'subr-x)

(defgroup ready-player-radio nil
  "Play live radio stations with ready-player."
  :group 'ready-player
  :prefix "ready-player-radio-")

(defcustom ready-player-radio-stations nil
  "Live radio stations as an alist of (NAME . STREAM-URL)."
  :group 'ready-player-radio
  :type '(alist :key-type (string :tag "Name")
                :value-type (string :tag "Stream URL")))

(defcustom ready-player-radio-directory
  (locate-user-emacs-file "radio")
  "Directory holding the generated station stub files."
  :group 'ready-player-radio
  :type 'directory)

(defcustom ready-player-radio-extension "radio"
  "Extension of the station stub files.
Must also be in `ready-player-supported-audio' for ready-player to
claim these files."
  :group 'ready-player-radio
  :type 'string)

(defun ready-player-radio--file-name (name)
  "Return NAME as a safe file-name component."
  (string-trim (replace-regexp-in-string "[/\0]" "-" name)))

(defun ready-player-radio--station-file (name)
  "Return the stub file for the station called NAME."
  (expand-file-name (format "%s.%s"
                            (ready-player-radio--file-name name)
                            ready-player-radio-extension)
                    ready-player-radio-directory))

(defun ready-player-radio--sync ()
  "Write a stub file per station, dropping stubs of gone stations."
  (make-directory ready-player-radio-directory t)
  (let ((current))
    (pcase-dolist (`(,name . ,url) ready-player-radio-stations)
      (let ((file (ready-player-radio--station-file name))
            ;; mpv reads this as a playlist thanks to the #EXTM3U header, and
            ;; names the entry after #EXTINF.
            (content (format "#EXTM3U\n#EXTINF:-1,%s\n%s\n" name url)))
        (push file current)
        ;; Don't rewrite an unchanged stub: mpv may be reading it right now.
        (unless (equal content
                       (and (file-exists-p file)
                            (with-temp-buffer
                              (insert-file-contents file)
                              (buffer-string))))
          (with-temp-file file
            (insert content)))))
    (dolist (file (file-expand-wildcards
                   (expand-file-name (concat "*." ready-player-radio-extension)
                                     ready-player-radio-directory)))
      (unless (member file current)
        (delete-file file)))))

;;;###autoload
(defun ready-player-radio-station-p (file)
  "Return non-nil when FILE is a station stub, i.e. a live stream."
  (and file
       (equal (file-name-extension file) ready-player-radio-extension)
       (file-in-directory-p file ready-player-radio-directory)))

;;;###autoload
(defun ready-player-radio-station-name (file)
  "Return the station name FILE streams, or nil."
  (when (ready-player-radio-station-p file)
    (file-name-base file)))

;;;###autoload
(defun ready-player-radio ()
  "Play a live station from `ready-player-radio-stations'.
Play it with ready-player in the background, without displaying the
player buffer."
  (interactive)
  (unless ready-player-radio-stations
    (user-error "No stations in `ready-player-radio-stations'"))
  (let ((station (if (cdr ready-player-radio-stations)
                     (completing-read "Station: "
                                      ready-player-radio-stations nil t)
                   (caar ready-player-radio-stations))))
    (ready-player-radio--sync)
    (find-file-noselect (ready-player-radio--station-file station))))

(provide 'ready-player-radio)
