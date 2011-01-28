;;; note: on the initial (el-get), if magit is not installed and "git" is not
;;;       in your $PATH (remember, Emacs.app does not inherit environment
;;;       variables), el-get will error. Also, package.el doesn't seem to fetch
;;;       a package list so you'll need to M-x package-list-packages to
;;;       initialize it.

(require 'el-get)

(setq el-get-sources
      '(autopair browse-kill-ring coffee-mode color-theme
                 color-theme-chocolate-rain diminish dired+ django-mode el-get
                 emacs-w3m escreen full-ack gist growl haml-mode ipython json
                 magit markdown-mode mode-compile nxhtml package paredit pymacs
                 python-mode quack ruby-compilation ruby-mode rvm sass-mode
                 scratch smart-tab smex switch-window textile-mode undo-tree
                 yaml-mode yari yasnippet
             
                 ;; elpa
                 (:name dired-isearch :type elpa)
                 (:name htmlize :type elpa)
                 (:name inf-ruby :type elpa)
                 (:name js2-mode :type elpa)
                 (:name kill-ring-search :type elpa)
                 (:name ruby-electric :type elpa)
                 (:name slime :type elpa)
                 (:name textmate :type elpa)

                 ;; emacswiki
                 (:name el-expectations :type emacswiki)

                 ;; other
                 (:name rhtml-mode
                        :type git
                        :url "git://github.com/eschulte/rhtml.git"
                        :after (lambda ()
                                 (autoload 'rhtml-mode "rhtml-mode" nil t)
                                 (add-to-list 'auto-mode-alist '("\\.html\.erb$" . rhtml-mode))))
                 (:name rspec-mode
                        :type git
                        :url "git://github.com/pezra/rspec-mode.git"
                        :features rspec-mode)))

(el-get)

(provide 'mqt-el-get)
