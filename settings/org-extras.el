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
