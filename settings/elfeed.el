(use-package elfeed
  :ensure t
  :commands elfeed

  :preface
  (defconst m/elfeed-search-buffer-name "Elfeed"
    "Name of the Elfeed search buffer.")

  (defun m/elfeed-search-buffer (_orig)
    "Return the Elfeed search buffer using its configured name."
    (get-buffer-create m/elfeed-search-buffer-name))

  (defun m/elfeed-search-update (_orig &optional method)
    "Update the Elfeed search buffer, looking it up by configured name."
    (when elfeed-search--update-timer
      (cancel-timer elfeed-search--update-timer)
      (setq elfeed-search--update-timer nil))
    (when-let* ((buffer (get-buffer m/elfeed-search-buffer-name)))
      (if method
          (elfeed-search--update-immediately
           buffer (if (keywordp method) method :force))
        (setf elfeed-search--update-timer
              (run-at-time elfeed-search-update-delay nil
                           #'elfeed-search--update-immediately
                           buffer)))))

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

  :init
  (setq elfeed-search-print-entry-function #'m/elfeed-search-print-entry
        elfeed-show-refresh-function #'m/elfeed-show-refresh)

  :custom
  (elfeed-feeds '("feedbin:"))
  (elfeed-search-filter "+unread")
  (elfeed-search-sort-order 'descending)

  :hook
  ((elfeed-search-mode . m/elfeed-search-restore-leader)
   (elfeed-show-mode . m/elfeed-show-use-default-font))

  :general
  ("SPC r" '(elfeed :which-key "RSS reader"))

  :config
  (advice-add 'elfeed-search-buffer :around #'m/elfeed-search-buffer)
  (advice-add 'elfeed-search-update :around #'m/elfeed-search-update)
  (load-file "~/.emacs.d/lib/elfeed-feedbin.el")
  (elfeed-feedbin-enable))
