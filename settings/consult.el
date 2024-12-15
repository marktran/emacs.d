(use-package consult
  :ensure t

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
  (consult-preview-max-count 15))
