(use-package elfeed
  :ensure t
  :commands elfeed

  :preface
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
  (elfeed-feeds
   '(("https://sive.rs/articles.xml" :title "Derek Sivers" derek-sivers)
     ("https://boz.com/rss.xml" :title "Andrew Bosworth" andrew-bosworth)))
  (elfeed-search-sort-order 'descending)

  :hook
  (elfeed-show-mode . m/elfeed-show-use-default-font)

  :general
  ("SPC r" '(elfeed :which-key "RSS reader")))
