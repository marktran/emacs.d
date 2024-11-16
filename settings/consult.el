(use-package consult
  :custom
  (consult-buffer-filter '("\\` "
                           "*Backtrace*"
                           "*Compile-Log*"
                           "*Completions*"
                           "*eat*"
                           "*eshell"
                           "*Messages*"
                           "*scratch*"
                           "magit-process:"))
  (consult-preview-max-count 15))
