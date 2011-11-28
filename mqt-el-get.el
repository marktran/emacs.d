(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (end-of-buffer)
       (eval-print-last-sexp)))))

(setq el-get-sources
      '((:name goto-last-change
               :after (lambda ()
                        (global-set-key (kbd "C-x C-/") 'goto-last-change)))

        (:name magit
               :after (lambda ()
                        (global-set-key (kbd "C-x C-z") 'magit-status)))

        ;; elpa
        (:name dired-isearch :type elpa)
        (:name kill-ring-search :type elpa)
        (:name slime :type elpa)))

(setq packages
      (append
       '(autopair
         browse-kill-ring
         coffee-mode
         color-theme
         color-theme-chocolate-rain
         csv-mode
         diminish
         dired+
         el-expectations
         el-get
         emacs-w3m
         escreen
         full-ack
         growl
         haml-mode
         highlight-indentation
         inf-ruby
         json
         markdown-mode
         mode-compile
         nxhtml
         package
         paredit
         pymacs
         python-mode
         quack
         rhtml-mode
         rspec-mode
         ruby-compilation
         ruby-electric
         ruby-mode
         sass-mode
         scala-mode
         scratch
         session
         smart-tab
         smex
         switch-window
         textile-mode
         textmate
         undo-tree
         yaml-mode
         yari
         yasnippet)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync packages)

(provide 'mqt-el-get)
