(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (end-of-buffer)
       (eval-print-last-sexp)))))

(setq el-get-sources
      '((:name ack-and-a-half :type elpa)
        (:name dired-isearch :type elpa)
        (:name kill-ring-search :type elpa)
        (:name ujelly-theme
               :type elpa
               :post-init (add-to-list 'custom-theme-load-path default-directory))))

(setq packages
      (append
       '(ace-jump-mode
         browse-kill-ring
         coffee-mode
         csv-mode
         diminish
         dired+
         el-expectations
         el-get
         evil
         evil-leader
         evil-numbers
         evil-surround
         expand-region
         goto-chg
         growl
         haml-mode
         highlight-indentation
         ido-ubiquitous
         inf-ruby
         json
         magit
         magithub
         markdown-mode
         mode-compile
         package
         paredit
         python-mode
         rhtml-mode
         rspec-mode
         ruby-electric
         ruby-mode
         sass-mode
         scala-mode
         scratch
         scss-mode
         smart-tab
         smex
         textile-mode
         undo-tree
         yaml-mode
         yasnippet
         zencoding-mode)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync packages)
