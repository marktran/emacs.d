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

(defun m/org-capture-bookmark-popup ()
  "Run the bookmark capture template in a dedicated popup frame.
Target of the Hyprland SUPER+ALT+B binding, which launches
`emacsclient -c' with an `org-capture-popup' frame parameter; the
frame is deleted again when the capture is finalized or aborted
(`m/org-capture-popup-cleanup'), or when it fails to start."
  (condition-case nil
      (progn
        (org-capture nil "b")
        (delete-other-windows))
    ((error quit) (m/org-capture-popup-cleanup))))

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
