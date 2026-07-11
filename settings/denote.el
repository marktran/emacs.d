(use-package consult-denote
  :ensure t

  :config
  (consult-denote-mode))

(defun m/consult-notes-denote-display-keywords-right (keywords)
  "Display Denote KEYWORDS against the right edge of the minibuffer."
  (if keywords
      (let* ((text (concat consult-notes-denote-display-keywords-indicator
                           (mapconcat #'identity keywords " ")))
             (offset (1+ (string-width text))))
        (concat (propertize " " 'display
                            `(space :align-to (- right ,offset)))
                text))
    ""))

(use-package consult-notes
  :ensure t

  :custom
  (consult-notes-denote-title-margin 2)
  (consult-notes-denote-display-keywords-width 32)
  (consult-notes-denote-display-keywords-function
   #'m/consult-notes-denote-display-keywords-right)
  (consult-notes-denote-dir nil)
  (consult-notes-denote-annotate-function #'ignore)

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
  (denote-directory (expand-file-name "~/Dropbox/org"))
  (denote-dired-directories-include-subdirectories t)
  (denote-known-keywords '("meeting" "person"))
  (denote-rename-buffer-mode t)

  :hook
  (dired-mode . denote-dired-mode-in-directories)

  :config
  (setq denote-dired-directories (list denote-directory)))

(use-package denote-org
  :ensure t
  :after denote)

(use-package denote-journal
  :ensure t
  :after denote

  :hook
  (calendar-mode . denote-journal-calendar-mode)

  :custom
  (denote-journal-directory (expand-file-name "daily" denote-directory))
  (denote-journal-keyword "daily")
  (denote-journal-title-format 'day-date-month-year)

  :config
  (with-eval-after-load 'evil
    (evil-define-key 'normal calendar-mode-map
      (kbd "<RET>") 'denote-journal-calendar-new-or-existing)))
