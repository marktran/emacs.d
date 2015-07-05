(require 'package)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)

(unless (file-exists-p "~/.emacs.d/elpa/archives/melpa")
  (package-refresh-contents))

(package-initialize)
