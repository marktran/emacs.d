(use-package consult
  :ensure t
  :demand t

  :custom
  (consult-buffer-filter '("\\` "
                           "*Backtrace*"
                           "*Compile-Log*"
                           "*Completions*"
                           "*dashboard*"
                           "*ghostel*"
                           "*eshell"
                           "*Help*"
                           "*Messages*"
                           "*scratch*"
                           "magit-process:"))
  (consult-narrow-key "<")
  (consult-preview-max-count 15)
  (consult-widen-key ">"))
