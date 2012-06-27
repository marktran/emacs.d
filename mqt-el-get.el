(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (end-of-buffer)
       (eval-print-last-sexp)))))

(setq el-get-sources
      '((:name ack-and-a-half
               :type github
               :pkgname "jhelwig/ack-and-a-half"
               :after (progn
                        (autoload 'ack-and-a-half-same "ack-and-a-half" nil t)
                        (autoload 'ack-and-a-half "ack-and-a-half" nil t)
                        (autoload 'ack-and-a-half-find-file-samee "ack-and-a-half" nil t)
                        (autoload 'ack-and-a-half-find-file "ack-and-a-half" nil t)
                        ;; aliases
                        (defalias 'ack 'ack-and-a-half)
                        (defalias 'ack-same 'ack-and-a-half-same)
                        (defalias 'ack-find-file 'ack-and-a-half-find-file)
                        (defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)))

        ;; elpa
        (:name dired-isearch :type elpa)
        (:name kill-ring-search :type elpa)
        ;; (:name slime :type elpa)
        (:name ujelly-theme
               :type elpa
               :post-init (add-to-list 'custom-theme-load-path default-directory))))

(setq packages
      (append
       '(browse-kill-ring
         coffee-mode
         csv-mode
         diminish
         dired+
         el-expectations
         el-get
         emacs-w3m
         evil
         evil-leader
         evil-numbers
         evil-surround
         goto-chg
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
         quack
         rhtml-mode
         rspec-mode
         ;; ruby-compilation
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

(provide 'mqt-el-get)
