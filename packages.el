;; set SPC to nil before evil makes dired-mode-map the overriding map
(require 'dired)
(define-key dired-mode-map (kbd "SPC") nil)

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
        (:name grizzl
               :type github
               :pkgname "d11wtq/grizzl"
               :features grizzl)
        (:name fiplr
               :type github
               :pkgname "d11wtq/fiplr"
               :features fiplr)
        (:name ido-ubiquitous
               :type github
               :pkgname "technomancy/ido-ubiquitous")
        (:name emmet-mode
               :type github
               :pkgname "smihica/zencoding"
               :features emmet-mode)))

(setq packages
      (append
       '(ack-and-a-half
         buffer-move
         cl-lib
         coffee-mode
         diminish
         dired+
         el-expectations
         el-get
         evil
         evil-leader
         evil-numbers
         evil-surround
         expand-region
         flx
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
         org-mode
         package
         paredit
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
