(use-package org
  :ensure nil

  :custom
  (org-default-notes-file "~/Dropbox/org/now/inbox.org")
  (org-agenda-files (list org-default-notes-file
                          "~/Dropbox/org/now/gcal.org"))
  ;; Start agenda weeks on Sunday, matching the calendar's default.
  (org-agenda-start-on-weekday 0)
  (org-agenda-format-date #'m/org-agenda-format-date-aligned)

  ;; Agenda styling: thin rules and terse leaders instead of the ASCII
  ;; defaults. Org picks its own unicode defaults only when loaded under
  ;; a graphical display, which never happens in a daemon, so set them
  ;; explicitly. Faces are left to the active theme.
  (org-agenda-block-separator ?─)
  (org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄" "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄"))
  (org-agenda-current-time-string "◀── now ─────────────────────")
  ;; No %i icon slot and no `%-12:c' category column — with one inbox
  ;; and one calendar, the category repeats more than it informs.
  (org-agenda-prefix-format
   '((agenda . "  %?-12t% s")
     (todo . "  ")
     (tags . "  ")
     (search . "  ")))
  (org-agenda-scheduled-leaders '("" "%2d× "))
  (org-agenda-deadline-leaders '("Due  " "In %2dd  " "%2dd ago  "))

  ;; One line per item: hide DONE items from the calendar and collapse
  ;; scheduled+deadline duplicates into the more urgent entry.
  (org-agenda-skip-scheduled-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-timestamp-if-done t)
  (org-agenda-skip-scheduled-if-deadline-is-shown t)
  (org-agenda-skip-timestamp-if-deadline-is-shown t)

  ;; Put the window layout back the way it was when the agenda quits.
  (org-agenda-restore-windows-after-quit t)

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

  ;; Drop the banner headers ("Global list of TODO items of type: ALL",
  ;; "Week-agenda (W34):") from every agenda view; date lines and the
  ;; Sunday week numbers already carry that information. Custom agenda
  ;; commands can still let-bind their own headers.
  (setq org-agenda-overriding-header "")

  (defun m/org-agenda-format-date-aligned (date)
    "Format DATE like `org-agenda-format-date-aligned', but tag Sundays.
Weeks start on Sunday here (`org-agenda-start-on-weekday'), so put
the week number on Sunday, labeled with the ISO week of the Monday
it precedes, instead of tagging Mondays mid-row."
    (require 'cal-iso)
    (let* ((dayname (calendar-day-name date))
           (day (cadr date))
           (day-of-week (calendar-day-of-week date))
           (month (car date))
           (monthname (calendar-month-name month))
           (year (nth 2 date))
           (iso-week (org-days-to-iso-week
                      (1+ (calendar-absolute-from-gregorian date))))
           (weekstring (if (= day-of-week 0)
                           (format " W%02d" iso-week)
                         "")))
      (format "%-10s %2d %s %4d%s"
              dayname day monthname year weekstring)))

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
  (org-mode . org-modern-mode)
  ;; Render the same todo/priority/tag pills in agenda buffers.
  (org-agenda-finalize . org-modern-agenda)

  :config
  ;; org-modern builds tag pills out of display strings padded with plain
  ;; spaces, which hands visual-line-mode word-wrap break points between and
  ;; even *inside* the pills: a long headline can strand a pill's empty
  ;; leading padding at the end of one visual line and its label on the
  ;; next. Swap those spaces for no-break spaces (word-wrap only breaks on
  ;; ASCII space/tab), so the whole tag group wraps as one unit, just like
  ;; plain :tag: text does.
  (defun m/org-modern-tag-nobreak (orig)
    "Call ORIG (`org-modern--tag'), then make its pill padding non-breaking."
    ;; Bounds must be taken before ORIG runs: its searches clobber the
    ;; match data set by the font-lock keyword.
    (let ((beg (match-beginning 2))
          (end (match-end 2)))
      (funcall orig)
      ;; The pills now contain no-break spaces; don't highlight them with
      ;; the `nobreak-space' face in this buffer.
      (setq-local nobreak-char-display nil)
      (while (< beg end)
        (let ((next (or (next-single-property-change beg 'display nil end) end))
              (disp (get-text-property beg 'display)))
          (when (and (stringp disp) (string-search " " disp))
            (put-text-property beg next 'display
                               (replace-regexp-in-string " " "\u00A0" disp)))
          (setq beg next)))
      ;; Return nil like ORIG so font-lock applies no extra face.
      nil))

  (advice-add 'org-modern--tag :around #'m/org-modern-tag-nobreak))
