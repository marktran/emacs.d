(use-package consult
  :custom
  (consult-buffer-filter '("\\` "
                           "*Backtrace*"
                           "*Completions*"
                           "*eat*"
                           "*eshell"
                           "*Messages*"
                           "*scratch*"
                           "magit-process:")))
