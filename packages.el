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
      '((:name ag
               :type github
               :pkgname "Wilfred/ag.el")
        (:name flx
               :type github
               :pkgname "lewang/flx"
               :features flx-ido)
        (:name helm-ls-git
               :type github
               :pkgname "emacs-helm/helm-ls-git")
        (:name ido-ubiquitous
               :type github
               :pkgname "technomancy/ido-ubiquitous")
        (:name zencoding-mode
               :type github
               :pkgname "smihica/zencoding"
               :features zencoding-mode)))

(setq packages
      (append
       '(ack-and-a-half
         browse-kill-ring
         buffer-move
         cl-lib
         coffee-mode
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
         inf-ruby
         json
         magit
         markdown-mode
         mode-compile
         multiple-cursors
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
         yasnippet)
       (mapcar 'el-get-source-name el-get-sources)))

(el-get 'sync packages)
