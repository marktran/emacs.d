;;; elfeed.el --- Feedbin RSS reading with Elfeed

;; `SPC r' opens the Elfeed search listing in a buffer named `Index';
;; entries open in `View'.  Elfeed hard-codes its internal buffer names, so
;; both renames map through the `m/elfeed-buffer-names' table: `Index' by
;; overriding `elfeed-search-buffer' and redirecting the direct lookup
;; inside `elfeed-search-update', and `View' by filtering the name
;; `elfeed-show--buffer-name' returns.
;;
;; The listing shows only title and feed, filtered to unread and sorted
;; newest first.  `r' fetches feeds, `B' opens entries in the browser, `U'
;; toggles unread without moving point (also on visual selections in the
;; Index), and `d' and `u' scroll.  In an entry view, `SPC' scrolls down and
;; advances to the next unread entry at the end.  Entry views drop the Tags
;; header and render with the default fixed-pitch font.  Both modes display
;; `Elfeed' as their major-mode name.
;;
;; Evil bindings are applied from `evil-collection-setup-hook' because
;; evil-collection's Elfeed setup registers after this file's `:config'
;; and binds `SPC', `U', `u', `d', `g r', and `g R' itself.  Unbinding
;; `SPC' in the search buffer lets the global General leader through.
;;
;; Feedbin supplies subscriptions, entries, and unread/starred state via
;; `lib/elfeed-feedbin.el'; the sole entry in `elfeed-feeds' is the
;; synthetic `feedbin:' URL that triggers synchronization.

(use-package elfeed
  :ensure t
  :commands elfeed

  :preface
  (defconst m/elfeed-buffer-names
    '(("*elfeed-search*" . "Index")
      ("*elfeed-entry*" . "View"))
    "Renames for Elfeed's hard-coded buffer names.")

  (defun m/elfeed-rename-buffer (buffer-or-name)
    "Return the rename for Elfeed's internal BUFFER-OR-NAME.
Return BUFFER-OR-NAME unchanged when it has no rename."
    (or (and (stringp buffer-or-name)
             (cdr (assoc buffer-or-name m/elfeed-buffer-names)))
        buffer-or-name))

  (defun m/elfeed-search-buffer ()
    "Create and return the renamed Elfeed search buffer."
    (get-buffer-create (m/elfeed-rename-buffer "*elfeed-search*")))

  (defun m/elfeed-search-update (orig &rest args)
    "Run ORIG with ARGS against the renamed Elfeed search buffer.
`elfeed-search-update' looks up Elfeed's internal buffer name
directly, so redirect `get-buffer' through `m/elfeed-rename-buffer'."
    (let ((real-get-buffer (symbol-function 'get-buffer)))
      (cl-letf (((symbol-function 'get-buffer)
                 (lambda (buffer-or-name)
                   (funcall real-get-buffer
                            (m/elfeed-rename-buffer buffer-or-name)))))
        (apply orig args))))

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

  (defun m/elfeed-search-toggle-unread ()
    "Toggle unread on the selected entries without moving point."
    (interactive)
    (let ((elfeed-search-remain-on-entry t))
      (elfeed-search-toggle-all 'unread)))

  (defun m/elfeed-set-evil-bindings (mode _keymaps)
    "Set Evil bindings for Elfeed once evil-collection has set up MODE.
evil-collection's Elfeed setup runs after this file's `:config' and
would clobber bindings made there."
    (when (eq mode 'elfeed)
      (evil-define-key 'normal elfeed-search-mode-map
        (kbd "SPC") nil ; let the global General SPC leader through
        (kbd "B") #'elfeed-search-browse-url
        (kbd "U") #'m/elfeed-search-toggle-unread
        (kbd "d") #'evil-scroll-down
        (kbd "g r") nil
        (kbd "g R") nil
        (kbd "r") #'elfeed-search-fetch
        (kbd "u") #'evil-scroll-up)
      (evil-define-key 'visual elfeed-search-mode-map
        (kbd "U") #'m/elfeed-search-toggle-unread)
      (evil-define-key 'normal elfeed-show-mode-map
        (kbd "SPC") #'elfeed-show-scroll-up-or-next
        (kbd "B") #'elfeed-show-visit
        (kbd "d") #'evil-scroll-down
        (kbd "u") #'evil-scroll-up)))

  (defun m/elfeed-show-refresh ()
    "Render an Elfeed entry without the Tags header."
    (elfeed-show-refresh--mail-style)
    (let ((inhibit-read-only t))
      (save-excursion
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
  (elfeed-search-remain-on-entry '(show))
  (elfeed-search-sort-order 'descending)

  :hook
  ((elfeed-search-mode . m/elfeed-set-mode-name)
   (elfeed-show-mode . m/elfeed-show-use-default-font)
   (elfeed-show-mode . m/elfeed-set-mode-name))

  :general
  ("SPC r" '(elfeed :which-key "RSS reader"))

  :config
  (advice-add 'elfeed-search-buffer :override #'m/elfeed-search-buffer)
  (advice-add 'elfeed-search-update :around #'m/elfeed-search-update)
  (advice-add 'elfeed-show--buffer-name :filter-return #'m/elfeed-rename-buffer))

(use-package elfeed-feedbin
  :ensure nil
  :load-path "lib"
  :after elfeed
  :config
  (elfeed-feedbin-enable))
