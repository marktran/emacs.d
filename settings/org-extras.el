(defvar m/org-bookmarks-file "~/Dropbox/org/bookmarks.org"
  "Org file holding captured bookmarks.")

(defun m/org-bookmarks-visit ()
  "Visit `m/org-bookmarks-file' in a graphical frame, creating one if needed.
Usable interactively (SPC n b), but also robust to being evaluated
via `emacsclient -e' without a graphical frame selected."
  (interactive)
  (let ((frame (if (display-graphic-p)
                   (selected-frame)
                 (or (seq-find #'display-graphic-p (frame-list))
                     (make-frame)))))
    (select-frame-set-input-focus frame)
    (find-file m/org-bookmarks-file)))

(defun m/clipboard-text ()
  "Return the system clipboard text, or nil.
Prefer wl-paste on Wayland: it reads the clipboard through the
privileged data-control protocol, which works even when no Emacs
frame has focus — `current-kill' (via `gui-selection-value') comes
up empty there, e.g. in a just-created capture popup frame."
  (or (and (getenv "WAYLAND_DISPLAY")
           (executable-find "wl-paste")
           (let ((text (shell-command-to-string
                        "wl-paste --no-newline 2>/dev/null")))
             (and (not (string-blank-p text)) text)))
      (ignore-errors (current-kill 0))))

(defun m/org-capture-bookmark-link ()
  "Return an Org link for the HTTP(S) URL on the clipboard.
Fetch the page title for the link description, like
`org-insert-link-dwim'.  Return an empty string when the clipboard
does not hold a URL, and a bare link when the title cannot be
fetched.  Used by the \"b\" `org-capture' template (settings/org.el)."
  (let ((url (ignore-errors (string-trim (m/clipboard-text)))))
    (if (and url (string-match-p "\\`https?://" url))
        (org-link-make-string
         url
         (condition-case nil
             (with-current-buffer (url-retrieve-synchronously url t t 5)
               (require 'dom)
               (let ((title (dom-text (car (dom-by-tag
                                            (libxml-parse-html-region
                                             (point-min) (point-max))
                                            'title)))))
                 (and (not (string-blank-p title)) (string-trim title))))
           (error nil)))
      "")))

(defun m/org-capture-popup-cleanup ()
  "Delete the selected frame if it is a dedicated capture popup."
  (when (frame-parameter nil 'org-capture-popup)
    (delete-frame)))

(add-hook 'org-capture-after-finalize-hook #'m/org-capture-popup-cleanup)

(defun m/org-capture-popup--run (keys)
  "Run `org-capture' with template KEYS in the current popup frame.
A blank backdrop replaces whatever buffer the daemon happened to
have current, so the popup never flashes work in progress. The
frame is deleted again when the capture is finalized or aborted
(`m/org-capture-popup-cleanup'), or when it fails to start."
  (when (frame-parameter nil 'org-capture-popup)
    (switch-to-buffer (get-buffer-create " *org-capture-popup*"))
    (setq-local mode-line-format nil))
  (condition-case nil
      (progn
        (org-capture nil keys)
        (delete-other-windows))
    ((error quit) (m/org-capture-popup-cleanup))))

(defun m/org-capture-popup ()
  "Capture into any template from a dedicated popup frame.
Target of the Hyprland SUPER+ALT+C binding, which launches
`emacsclient -c' with an `org-capture-popup' frame parameter; the
template selector runs in the popup's minibuffer
(`m/org-capture-select-template')."
  (m/org-capture-popup--run nil))

(defun m/org-capture-bookmark-popup ()
  "Run the bookmark capture template in a dedicated popup frame.
Target of the Hyprland SUPER+ALT+B binding; see
`m/org-capture-popup--run' for the frame lifecycle."
  (m/org-capture-popup--run "b"))

(defun m/org-capture-select-template (&optional keys)
  "Select a capture template with `completing-read'.
`:override' advice for `org-capture-select-template', replacing
the *Org Select* text-menu buffer with the minibuffer (vertico).
KEYS picks a template directly, as in the original."
  (let ((templates (or (org-contextualize-keys
                        (org-capture-upgrade-templates org-capture-templates)
                        org-capture-templates-contexts)
                       '(("t" "Task" entry (file+headline "" "Tasks")
                          "* TODO %?\n  %u\n  %a")))))
    (if keys
        (or (assoc keys templates)
            (error "No capture template referred to by \"%s\" keys" keys))
      (let* ((candidates
              (mapcar (lambda (template)
                        (cons (format "%-3s%s" (nth 0 template) (nth 1 template))
                              template))
                      ;; Entries with only a key and description are
                      ;; group headings for the *Org Select* menu.
                      (seq-filter (lambda (template) (> (length template) 2))
                                  templates)))
             (table (lambda (string predicate action)
                      (if (eq action 'metadata)
                          '(metadata (display-sort-function . identity)
                                     (cycle-sort-function . identity))
                        (complete-with-action action candidates string predicate))))
             (choice (completing-read "Capture template: " table nil t)))
        (cdr (assoc choice candidates))))))

(advice-add 'org-capture-select-template :override #'m/org-capture-select-template)

(defun m/org-capture-drawer-p (buffer-name _action)
  "Match capture buffers, except in dedicated popup frames.
Popup frames (`org-capture-popup' frame parameter) show the
capture buffer as their only window instead."
  (and (string-prefix-p "CAPTURE-" buffer-name)
       (not (frame-parameter nil 'org-capture-popup))))

;; Show capture buffers in a bottom drawer instead of splitting
;; whichever window happened to be selected.
(add-to-list 'display-buffer-alist
             '(m/org-capture-drawer-p
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.35)))

(defun m/org-capture-tidy ()
  "Declutter the capture buffer and start typing immediately.
Drop the verbose \"Finish C-c C-c...\" header line (ZZ/ZQ/ZR
cover it, see settings/evil.el) and enter insert state at the
template's %? slot."
  (when org-capture-mode
    (setq header-line-format nil)
    (evil-insert-state)))

(add-hook 'org-capture-mode-hook #'m/org-capture-tidy)

(defun org-insert-link-dwim ()
  "Insert an Org link with smart context-based behavior.

When the clipboard contains an HTTP(S) URL:
- With active region: Create link using region text as description
- Without active region: Prompt for description, defaulting to webpage title
  from the URL

Falls back to `org-insert-link' when:
- Cursor is inside an existing link
- Clipboard doesn't contain an HTTP(S) URL"
  (interactive)
  (let* ((point-in-link (org-in-regexp org-link-any-re 1))
         ;; Improved URL detection by checking kill-ring first
         (clipboard-url (and kill-ring
                           (string-match-p "^https?" (current-kill 0))
                           (current-kill 0)))
         (region-content (when (region-active-p)
                          (buffer-substring-no-properties
                           (region-beginning)
                           (region-end)))))
    (cond
     ;; Case 1: Active region + URL in clipboard
     ((and region-content clipboard-url (not point-in-link))
      (delete-region (region-beginning) (region-end))
      (insert (org-link-make-string clipboard-url region-content)))

     ;; Case 2: No region + URL in clipboard
     ((and clipboard-url (not point-in-link))
      (insert (org-link-make-string
               clipboard-url
               (read-string "title: "
                          (condition-case nil
                              (with-current-buffer
                                  (url-retrieve-synchronously clipboard-url t)
                                (dom-text (car
                                         (dom-by-tag
                                          (libxml-parse-html-region
                                           (point-min)
                                           (point-max))
                                          'title))))
                            (error ""))))))

     ;; Case 3: Fallback to standard org-insert-link
     (t
      (call-interactively 'org-insert-link)))))

(defun org-yank-dwim ()
  "Yank with smart context-based behavior.

If text is selected (region is active):
- If the kill ring contains an HTTP(S) URL, replace the region with a link
  using the URL and the region content as the description
- Otherwise, replace the region with the yanked text

If no region is active and the kill ring contains an HTTP(S) URL:
- If we're inside a link, fall back to regular `org-yank'
- Otherwise, prompt for a description (defaulting to webpage title) and
  create a link

In all other cases, fall back to `org-yank'."
  (interactive)
  (let* ((point-in-link (org-in-regexp org-link-any-re 1))
         (clipboard-url (when (and (not (null kill-ring))
                                 (string-match-p "^http" (current-kill 0)))
                        (current-kill 0)))
         (region-content (when (region-active-p)
                          (buffer-substring-no-properties
                           (region-beginning)
                           (region-end)))))
    (cond
     ;; Case 1: Active region + URL in clipboard
     ((and region-content clipboard-url (not point-in-link))
      (delete-region (region-beginning) (region-end))
      (insert (org-link-make-string clipboard-url region-content)))

     ;; Case 2: Active region + non-URL in clipboard
     (region-content
      (delete-region (region-beginning) (region-end))
      (yank))

     ;; Case 3: No region + URL in clipboard
     ((and clipboard-url (not point-in-link))
      (insert (org-link-make-string
               clipboard-url
               (read-string "title: "
                          (with-current-buffer
                              (url-retrieve-synchronously clipboard-url)
                            (dom-text (car
                                     (dom-by-tag
                                      (libxml-parse-html-region
                                       (point-min)
                                       (point-max))
                                      'title))))))))

     ;; Case 4: Fallback
     (t
      (call-interactively 'org-yank)))))

(use-package org-autolist
  :ensure t
  :after org
  :diminish org-autolist-mode

  :hook
  (org-mode . org-autolist-mode))

(use-package evil-org
  :ensure t
  :after org
  :diminish evil-org-mode

  :hook
  (org-mode . evil-org-mode)

  :config
  (evil-org-set-key-theme))
