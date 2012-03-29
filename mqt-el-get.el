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
               :after (progn
                        (global-set-key (kbd "C-x C-/") 'goto-last-change)))

        (:name color-theme-ujelly
         :type github
         :pkgname "marktran/color-theme-ujelly"
         :depends color-theme
         :prepare (progn
                    (autoload 'color-theme-ujelly "color-theme-ujelly"
                      "color-theme: ujelly" t)))

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
         csv-mode
         diminish
         el-expectations
         el-get
         emacs-w3m
         evil
         evil-leader
         evil-numbers
         growl
         haml-mode
         highlight-indentation
         inf-ruby
         json
         magit
         markdown-mode
         mode-compile
         package
         paredit
         python-mode
         rspec-mode
         ruby-compilation
         ruby-electric
         ruby-mode
         sass-mode
         scala-mode
         scratch
         smart-tab
         smex
         switch-window
         textile-mode
         textmate
         undo-tree
         yaml-mode
         yasnippet)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync packages)

(provide 'mqt-el-get)
