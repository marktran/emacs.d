(defun beframe-buffer-names-sorted (&optional frame)
  "Return the list of buffers from `beframe-buffer-names' sorted by visibility.
With optional argument FRAME, return the list of buffers of FRAME."
  (beframe-buffer-names frame :sort #'beframe-buffer-sort-visibility))

(use-package consult
  :ensure t
  :demand t

  :custom
  (consult-buffer-filter '("\\` "
                           "*Backtrace*"
                           "*Compile-Log*"
                           "*Completions*"
                           "*dashboard*"
                           "*eat*"
                           "*eshell"
                           "*Help*"
                           "*Messages*"
                           "*scratch*"
                           "magit-process:"))
  (consult-narrow-key "<")
  (consult-preview-max-count 15)
  (consult-widen-key ">")

  :custom-face
  (beframe-buffer ((t (:inherit font-lock-string-face))))

  :config
  (defvar beframe-consult-source
    `( :name     "Frame-specific buffers (current frame)"
       :narrow   ?F
       :category buffer
       :face     beframe-buffer
       :history  beframe-history
       :items    ,#'beframe-buffer-names-sorted
       :action   ,#'switch-to-buffer
       :state    ,#'consult--buffer-state)))
