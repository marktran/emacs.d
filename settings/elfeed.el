(use-package elfeed
  :ensure t
  :commands elfeed

  :preface
  (defconst m/elfeed-search-buffer-name "List"
    "Name of the Elfeed search buffer.")

  (defconst m/elfeed-show-buffer-name "View"
    "Name of the Elfeed entry buffer.")

  (defun m/elfeed-search-buffer (orig)
    "Return Elfeed's search buffer, renamed for display."
    (or (get-buffer m/elfeed-search-buffer-name)
        (let ((buffer (funcall orig)))
          (with-current-buffer buffer
            (rename-buffer m/elfeed-search-buffer-name))
          buffer)))

  (defun m/elfeed-search-update (orig &rest args)
    "Run ORIG against the renamed Elfeed search buffer with ARGS."
    (if-let* ((buffer (get-buffer m/elfeed-search-buffer-name)))
        (unwind-protect
            (progn
              ;; `elfeed-search-update' looks up this internal name directly.
              (with-current-buffer buffer
                (rename-buffer "*elfeed-search*"))
              (apply orig args))
          (when (buffer-live-p buffer)
            (with-current-buffer buffer
              (rename-buffer m/elfeed-search-buffer-name))))
      (apply orig args)))

  (defun m/elfeed-show-buffer-name (orig entry)
    "Return Elfeed's show buffer name for ENTRY, replacing the default."
    (let ((name (funcall orig entry)))
      (if (not (equal name "*elfeed-entry*"))
          name
        (unless (get-buffer m/elfeed-show-buffer-name)
          (when-let* ((buffer (get-buffer name)))
            (with-current-buffer buffer
              (rename-buffer m/elfeed-show-buffer-name))))
        m/elfeed-show-buffer-name)))

  (defun m/elfeed-search-print-entry (entry)
    "Print ENTRY as title and feed."
    (let* ((title (or (elfeed-meta--title entry)
                      (elfeed-entry-link entry)
                      ""))
           (feed (elfeed-entry-feed entry))
           (feed-title (or (and feed (elfeed-meta--title feed)) ""))
           (window (get-buffer-window (current-buffer)))
           (width (if window (window-width window) (frame-width)))
           (title-width (max 16 (- width (string-width feed-title) 3))))
      (insert
       (propertize (elfeed-format-column title title-width :left)
                   'face (elfeed-search--faces (elfeed-entry-tags entry))
                   'mouse-face 'highlight
                   'follow-link [elfeed-entry])
       "  "
       (propertize feed-title
                   'face 'elfeed-search-feed-face
                   'mouse-face 'highlight
                   'follow-link [elfeed-feed]))))

  (defun m/elfeed-search-restore-leader ()
    "Let the global General SPC leader apply in Elfeed search buffers."
    (general-define-key
     :states 'normal
     :keymaps 'elfeed-search-mode-map
     "SPC" nil))

  (defun m/elfeed-show-refresh ()
    "Render an Elfeed entry without the Tags header."
    (elfeed-show-refresh--mail-style)
    (let ((inhibit-read-only t))
      (save-excursion
        (goto-char (point-min))
        (let ((header-end (save-excursion (search-forward "\n\n" nil t))))
          (when (re-search-forward "^Tags:.*\n" header-end t)
            (delete-region (match-beginning 0) (match-end 0)))))))

  (defun m/elfeed-show-use-default-font ()
    "Render entry content using the default fixed-pitch font."
    (setq-local shr-use-fonts nil))

  (defun m/elfeed-set-mode-name ()
    "Display the current Elfeed major mode as Elfeed."
    (setq-local mode-name "Elfeed"))

  :init
  (setq elfeed-search-print-entry-function #'m/elfeed-search-print-entry
        elfeed-show-refresh-function #'m/elfeed-show-refresh)

  :custom
  (elfeed-feeds '("feedbin:"))
  (elfeed-search-filter "+unread")
  (elfeed-search-sort-order 'descending)

  :hook
  ((elfeed-search-mode . m/elfeed-search-restore-leader)
   (elfeed-search-mode . m/elfeed-set-mode-name)
   (elfeed-show-mode . m/elfeed-show-use-default-font)
   (elfeed-show-mode . m/elfeed-set-mode-name))

  :general
  ("SPC r" '(elfeed :which-key "RSS reader"))

  :config
  (advice-add 'elfeed-search-buffer :around #'m/elfeed-search-buffer)
  (advice-add 'elfeed-search-update :around #'m/elfeed-search-update)
  (advice-add 'elfeed-show--buffer-name :around #'m/elfeed-show-buffer-name)
  (load-file "~/.emacs.d/lib/elfeed-feedbin.el")
  (elfeed-feedbin-enable))
