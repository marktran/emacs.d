(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(use-package use-package
  :custom
  (use-package-compute-statistics t))
