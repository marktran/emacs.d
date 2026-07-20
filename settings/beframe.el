(use-package beframe
  :ensure t
  :demand t

  :preface
  (defun m/beframe-buffer-names-sorted (&optional frame)
    "Return the list of buffers from `beframe-buffer-names' sorted by visibility.
With optional argument FRAME, return the list of buffers of FRAME."
    (beframe-buffer-names frame :sort #'beframe-buffer-sort-visibility))

  :custom
  (beframe-global-buffers nil)

  :config
  (beframe-mode t)

  ;; Offer the current frame's buffers as a narrowable `consult-buffer'
  ;; source, per the beframe manual.
  (defface beframe-buffer
    '((t :inherit font-lock-string-face))
    "Face for `consult' framed buffers.")

  (with-eval-after-load 'consult
    (defvar beframe-consult-source
      `( :name     "Frame-specific buffers (current frame)"
         :narrow   ?F
         :category buffer
         :face     beframe-buffer
         :history  beframe-history
         :items    ,#'m/beframe-buffer-names-sorted
         :action   ,#'switch-to-buffer
         :state    ,#'consult--buffer-state))
    (add-to-list 'consult-buffer-sources 'beframe-consult-source)))
