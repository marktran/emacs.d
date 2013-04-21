;; set before el-get loads packages
(setq evil-want-C-u-scroll t)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (end-of-buffer)
       (eval-print-last-sexp)))))

(setq el-get-sources
      '((:name helm-ls-git
               :type github
               :pkgname "emacs-helm/helm-ls-git")))

(setq packages
      (append
       '(ace-jump-mode
         ack-and-a-half
         browse-kill-ring
         buffer-move
         cl-lib
         coffee-mode
         csv-mode
         diminish
         dired+
         el-expectations
         el-get
         eshell-autojump
         evil
         evil-leader
         evil-numbers
         evil-surround
         expand-region
         golden-ratio
         goto-chg
         growl
         haml-mode
         helm
         highlight-indentation
         ido-ubiquitous
         json
         magit
         markdown-mode
         mode-compile
         package
         paredit
         projectile
         python-mode
         rhtml-mode
         rspec-mode
         ruby-electric
         ruby-mode
         scratch
         smart-tab
         smex
         ujelly-theme
         undo-tree
         window-numbering
         yaml-mode
         yasnippet
         zencoding-mode)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync packages)
