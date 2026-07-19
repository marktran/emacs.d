;;; elfeed.el --- Feedbin RSS reading with Elfeed

;; `SPC r' opens the Elfeed search listing in a buffer named `Index';
;; entries open in `View'. Elfeed hard-codes its internal buffer names, so
;; both renames are advice: `Index' overrides `elfeed-search-buffer' and
;; redirects the one direct `get-buffer' lookup inside
;; `elfeed-search-update'; `View' overrides `elfeed-show--buffer-name'.
;;
;; The listing shows only title and feed, filtered to unread and sorted
;; newest first. Starred titles end in `*' in both the listing and entry
;; view.  `r' fetches feeds and `B' opens entries in the browser. `s'
;; toggles the Feedbin star and `U' toggles unread without moving point;
;; both work on visual selections in the Index.
;; `TAB' switches between unread Index entries and all Starred entries
;; (shown as `Starred' in the mode line). `d' and `u' scroll. In an
;; entry view, `SPC' scrolls down and advances to the next unread entry at
;; the end.
;; Entry views drop the Tags header and render with the default fixed-pitch
;; font. Both modes display `Elfeed' as their major-mode name.
;;
;; Evil bindings are applied from `evil-collection-setup-hook' because
;; evil-collection's Elfeed setup registers after this file's `:config'
;; and binds `SPC', `U', `u', `d', `g r', and `g R' itself. Unbinding
;; `SPC' in the search buffer lets the global General leader through.
;;
;; Feedbin supplies subscriptions, entries, and unread/starred state via
;; `lib/elfeed-feedbin.el'; the sole entry in `elfeed-feeds' is the
;; synthetic `feedbin:' URL that triggers synchronization.

(use-package elfeed
  :ensure t
  :commands elfeed

  :preface
  (defvar elfeed-feedbin-star-tag)

  (defun m/elfeed-search-buffer ()
    "Create and return the renamed Elfeed search buffer."
    (get-buffer-create "Index"))

  (defun m/elfeed-show-buffer-name (_entry)
    "Return the rename for Elfeed's hard-coded entry buffer name."
    "View")

  (defun m/elfeed-search-update (orig &rest args)
    "Run ORIG with ARGS against the renamed Elfeed search buffer.
`elfeed-search-update' looks up Elfeed's internal buffer name
directly, so redirect that one `get-buffer' call."
    (cl-letf* ((real-get-buffer (symbol-function 'get-buffer))
               ((symbol-function 'get-buffer)
                (lambda (buffer-or-name)
                  (funcall real-get-buffer
                           (if (equal buffer-or-name "*elfeed-search*")
                               "Index"
                             buffer-or-name)))))
      (apply orig args)))

  (defun m/elfeed-search-print-entry (entry)
    "Print ENTRY as title and feed."
    (let* ((title (or (elfeed-meta--title entry)
                      (elfeed-entry-link entry)
                      ""))
           (feed (elfeed-entry-feed entry))
           (feed-title (or (and feed (elfeed-meta--title feed)) ""))
           (window (get-buffer-window (current-buffer)))
           (width (if window (window-width window) (frame-width)))
           (title-width (max 16 (- width (string-width feed-title) 3)))
           (display-title
            (if (elfeed-tagged-p elfeed-feedbin-star-tag entry)
                (concat (truncate-string-to-width title (1- title-width)) "*")
              title)))
      (insert
       (propertize (elfeed-format-column display-title title-width :left)
                   'face (elfeed-search--faces (elfeed-entry-tags entry))
                   'mouse-face 'highlight
                   'follow-link [elfeed-entry])
       "  "
       (propertize feed-title
                   'face 'elfeed-search-feed-face
                   'mouse-face 'highlight
                   'follow-link [elfeed-feed]))))

  (defun m/elfeed-search-toggle-unread ()
    "Toggle unread on the selected entries."
    (interactive)
    (elfeed-search-toggle-all 'unread))

  (defun m/elfeed-search-toggle-star ()
    "Toggle the Feedbin star on selected entries."
    (interactive)
    (elfeed-search-toggle-all elfeed-feedbin-star-tag))

  (defun m/elfeed-show-toggle-star ()
    "Toggle the Feedbin star on the displayed entry."
    (interactive)
    (if (elfeed-tagged-p elfeed-feedbin-star-tag elfeed-show-entry)
        (elfeed-show-untag elfeed-feedbin-star-tag)
      (elfeed-show-tag elfeed-feedbin-star-tag)))

  (defun m/elfeed-search-starred-p ()
    "Return non-nil when the current Elfeed filter requires a Feedbin star."
    (member (format "+%s" elfeed-feedbin-star-tag)
            (split-string elfeed-search-filter)))

  (defun m/elfeed-search-toggle-index-starred ()
    "Switch between the unread Index and all Feedbin Starred entries."
    (interactive)
    (elfeed-search-set-filter
     (if (m/elfeed-search-starred-p)
         (default-value 'elfeed-search-filter)
       (format "+%s" elfeed-feedbin-star-tag))))

  (defun m/elfeed-set-search-mode-line-identification ()
    "Identify the current Elfeed search view in the mode line."
    (setq-local mode-line-buffer-identification
                '(:eval (propertized-buffer-identification
                         (format "%-12s"
                                 (if (m/elfeed-search-starred-p)
                                     "Starred"
                                   "Index"))))))

  (defun m/elfeed-set-evil-bindings (mode _keymaps)
    "Set Evil bindings for Elfeed once evil-collection has set up MODE.
evil-collection's Elfeed setup runs after this file's `:config' and
would clobber bindings made there."
    (when (eq mode 'elfeed)
      (evil-define-key 'normal elfeed-search-mode-map
        (kbd "SPC") nil ; let the global General SPC leader through
        (kbd "TAB") #'m/elfeed-search-toggle-index-starred
        (kbd "<tab>") #'m/elfeed-search-toggle-index-starred
        (kbd "B") #'elfeed-search-browse-url
        (kbd "U") #'m/elfeed-search-toggle-unread
        (kbd "d") #'evil-scroll-down
        (kbd "g r") nil
        (kbd "g R") nil
        (kbd "r") #'elfeed-search-fetch
        (kbd "s") #'m/elfeed-search-toggle-star
        (kbd "u") #'evil-scroll-up)
      (evil-define-key 'visual elfeed-search-mode-map
        (kbd "s") #'m/elfeed-search-toggle-star
        (kbd "U") #'m/elfeed-search-toggle-unread)
      (evil-define-key 'normal elfeed-show-mode-map
        (kbd "SPC") #'elfeed-show-scroll-up-or-next
        (kbd "B") #'elfeed-show-visit
        (kbd "d") #'evil-scroll-down
        (kbd "s") #'m/elfeed-show-toggle-star
        (kbd "u") #'evil-scroll-up)))

  (defun m/elfeed-show-refresh ()
    "Render an Elfeed entry with a star indicator and no Tags header."
    (elfeed-show-refresh--mail-style)
    (let ((inhibit-read-only t))
      (save-excursion
        (goto-char (point-min))
        (when (elfeed-tagged-p elfeed-feedbin-star-tag elfeed-show-entry)
          (end-of-line)
          (insert (propertize "*" 'face 'elfeed-show-title-face)))
        (goto-char (point-min))
        (when-let* ((header-end (save-excursion (search-forward "\n\n" nil t))))
          (when (re-search-forward "^Tags:.*\n" header-end t)
            (replace-match ""))))))

  (defun m/elfeed-show-use-default-font ()
    "Render entry content using the default fixed-pitch font."
    (setq-local shr-use-fonts nil))

  (defun m/elfeed-set-mode-name ()
    "Display the current Elfeed major mode as Elfeed."
    (setq-local mode-name "Elfeed"))

  :init
  (add-hook 'evil-collection-setup-hook #'m/elfeed-set-evil-bindings)
  ;; Plain defvars, not defcustoms, so `:custom' would not apply them.
  (setq elfeed-search-print-entry-function #'m/elfeed-search-print-entry
        elfeed-show-refresh-function #'m/elfeed-show-refresh)

  :custom
  (elfeed-feeds '("feedbin:"))
  (elfeed-search-filter "+unread")
  ;; Keep point on the current entry after showing or tagging it.
  (elfeed-search-remain-on-entry '(show tag))
  (elfeed-search-sort-order 'descending)

  :hook
  ((elfeed-search-mode . m/elfeed-set-mode-name)
   (elfeed-search-mode . m/elfeed-set-search-mode-line-identification)
   (elfeed-show-mode . m/elfeed-show-use-default-font)
   (elfeed-show-mode . m/elfeed-set-mode-name))

  :general
  ("SPC r" '(elfeed :which-key "RSS reader"))

  :config
  (advice-add 'elfeed-search-buffer :override #'m/elfeed-search-buffer)
  (advice-add 'elfeed-search-update :around #'m/elfeed-search-update)
  (advice-add 'elfeed-show--buffer-name :override #'m/elfeed-show-buffer-name))

(use-package elfeed-feedbin
  :ensure nil
  :load-path "lib"
  :after elfeed
  :config
  (elfeed-feedbin-enable))
