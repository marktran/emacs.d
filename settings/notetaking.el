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

(use-package org
  :ensure nil
  :demand t

  :custom
  (org-log-done 'time)
  (org-src-fontify-natively t)

  :hook
  (org-mode . visual-line-mode)

  :general
  (:keymaps 'org-mode-map
   :states 'normal
   "za" 'org-cycle
   "zA" 'org-shifttab
   "zc" 'outline-hide-subtree
   "zm" 'outline-hide-body
   "zo" 'outline-show-subtree
   "zr" 'outline-show-all

   "RET" 'org-open-at-point
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup)

  (:keymaps 'org-mode-map
   :states 'visual
   :keymaps 'org-mode-map
   "s-v" 'org-insert-link-dwim)

  (:keymaps 'org-mode-map
   :states 'insert
   "s-v" 'org-yank-dwim
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup))

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

(use-package consult-denote
  :ensure t

  :config
  (consult-denote-mode))

(use-package consult-notes
  :ensure t

  :custom-face
  (consult-notes-name ((t (:inherit marginalia-file-priv-rare))))
  (consult-notes-sep ((t (:inherit completions-group-title))))
  (consult-notes-size ((t (:inherit marginalia-size))))
  (consult-notes-time ((t (:inherit marginalia-modified))))

  :config
  (consult-notes-denote-mode))

(use-package denote
  :ensure t

  :custom
  (denote-directory (expand-file-name "~/Documents/denote"))
  (denote-dired-directories-include-subdirectories t)
  (denote-known-keywords '("meeting" "person"))
  (denote-rename-buffer-mode t)

  :hook
  (dired-mode . denote-dired-mode-in-directories)

  :general
  (:prefix "SPC n"
   "" '(:ignore t :which-key "Notes")
   "c" '(denote-create-note :which-key "Create note")
   "d" '(denote-journal-extras-new-or-existing-entry :which-key "Jump to daily entry")
   "f" '(consult-notes :which-key "Find notes")
   "s" '(consult-denote-grep :which-key "Search notes"))

  :config
  (setq denote-dired-directories (list denote-directory)))

(use-package denote-journal
  :ensure t

  :custom
  (denote-journal-extras-directory (expand-file-name "journal" denote-directory))
  (denote-journal-extras-title-format 'day-date-month-year))
