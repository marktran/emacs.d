(use-package org
  :ensure nil

  :custom
  (org-default-notes-file "~/Dropbox/org/now/inbox.org")
  (org-agenda-files (list org-default-notes-file))
  (org-log-done 'time)

  (org-capture-templates
   '(("t" "Task" entry (file org-default-notes-file)
      "* TODO %?\n  %U\n  %a\n  %i")
     ;; Newest first; the link comes from the clipboard URL with its
     ;; page title fetched (m/org-capture-bookmark-link, org-extras.el).
     ("b" "Bookmark" entry (file m/org-bookmarks-file)
      "* %(m/org-capture-bookmark-link)\n%U\n%?"
      :prepend t
      :empty-lines-after 1)))

  :hook
  (org-mode . visual-line-mode)

  :general
  (:keymaps 'org-mode-map
   :states '(normal insert)
   "M-j" 'org-shiftleft
   "M-k" 'org-shiftright
   "M-H" 'org-metaleft
   "M-J" 'org-metadown
   "M-L" 'org-metaright
   "M-K" 'org-metaup)
  (:keymaps 'org-mode-map
   :states 'normal
   "za" 'org-cycle
   "zA" 'org-shifttab
   "zc" 'outline-hide-subtree
   "zm" 'outline-hide-body
   "zo" 'outline-show-subtree
   "zr" 'outline-show-all
   "RET" 'org-open-at-point)
  (:keymaps 'org-mode-map
   :states 'visual
   "s-v" 'org-insert-link-dwim)
  (:keymaps 'org-mode-map
   :states 'insert
   "s-v" 'org-yank-dwim
   "TAB" 'm/org-tab-dwim
   "<backtab>" 'm/org-backtab-dwim)

  :config
  ;; Follow file-backed links (file:, denote:, ...) in the same window
  ;; instead of Org's default `find-file-other-window' split.
  (setf (alist-get 'file org-link-frame-setup) #'find-file)

  (defun m/org-tab-dwim ()
    "Indent the list item at point, but keep TAB's usual behavior elsewhere."
    (interactive)
    (if (and (org-at-item-p) (not (org-at-table-p)))
        (org-metaright)
      (org-cycle)))

  (defun m/org-backtab-dwim ()
    "De-indent, but keep S-TAB's previous-field behavior in tables."
    (interactive)
    (if (org-at-table-p) (org-table-previous-field) (org-metaleft)))

  (defun m/org-agenda-hide-ddl-and-grid (&rest _)
    "Hide Ddl and Grid status markers from the org-agenda mode line."
    (when (and (eq major-mode 'org-agenda-mode)
               (listp mode-name))
      (setq mode-name (remove " Ddl" (remove " Grid" mode-name)))
      (force-mode-line-update)))

  (advice-add 'org-agenda-set-mode-name :after #'m/org-agenda-hide-ddl-and-grid))

;; Modern styling for Org buffers, feature by feature: tables get
;; thin pixel-drawn borders instead of ASCII "|" and "-"; tags,
;; TODO keywords, and priorities render as pill labels (headline-only
;; elements, so they cannot skew table alignment). The rest is
;; explicitly disabled; flip things on here as desired.
(use-package org-modern
  :ensure t

  :custom
  ;; Tables — the reason this package is here
  (org-modern-table t)
  (org-modern-table-vertical 1)  ; border width in px (default 3, nil hides)

  ;; Tags
  (org-modern-tag t)

  ;; Keyword lines (frontmatter): hide the "#+" prefix
  (org-modern-keyword t)

  ;; TODO keyword and priority labels
  (org-modern-todo t)
  (org-modern-priority t)

  ;; Everything else off, for now
  ;; NB: timestamp chips resize timestamps (condensed 0.8-height face),
  ;; which misaligns the borders of any table containing them
  ;; (https://github.com/minad/org-modern/issues/5), so keep them off.
  (org-modern-timestamp nil)
  (org-modern-star nil)
  (org-modern-hide-stars nil)
  (org-modern-list nil)
  (org-modern-checkbox nil)
  (org-modern-horizontal-rule nil)
  (org-modern-block-name nil)
  (org-modern-block-fringe nil)
  (org-modern-footnote nil)
  (org-modern-internal-target nil)
  (org-modern-radio-target nil)
  (org-modern-progress nil)

  :hook
  (org-mode . org-modern-mode))
