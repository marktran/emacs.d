;;; note: on the initial (el-get), if magit is not installed and "git" is not
;;;       in your $PATH (remember, Emacs.app does not inherit environment
;;;       variables), el-get will error. Also, package.el doesn't seem to fetch
;;;       a package list so you'll need to M-x package-list-packages to
;;;       initialize it.

(require 'el-get)

(setq el-get-sources
      '(apel autopair color-theme coffee-mode diminish dired+ django-mode
             el-get emacs-w3m gist haml-mode ipython json magit markdown-mode
             mode-compile nxhtml package paredit pymacs python-mode quack
             ruby-compilation ruby-mode rvm sass-mode smex switch-window 
             textile-mode undo-tree yaml-mode yari yasnippet
             
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
             (:name browse-kill-ring :type emacswiki)

             ;; other
             (:name color-theme-chocolate-rain
                    :type git
                    :url "git://github.com/marktran/color-theme-chocolate-rain.git"
                    :load "color-theme-chocolate-rain.el"
                    :after (lambda () (color-theme-chocolate-rain)))
             (:name full-ack
                    :type git
                    :url "git://github.com/nschum/full-ack.git")
             (:name growl
                    :type http
                    :url "http://edward.oconnor.cx/elisp/growl.el"
                    :after (lambda ()
                             (autoload 'growl "growl" nil t)))
             (:name peepopen
                    :type git
                    :url "git://github.com/topfunky/PeepOpen-EditorSupport.git"
                    :features peepopen)
             (:name rhtml-mode
                    :type git
                    :url "git://github.com/eschulte/rhtml.git"
                    :compile "rhtml-mode.el")
             (:name rspec-mode
                    :type git
                    :url "git://github.com/pezra/rspec-mode.git"
                    :features rspec-mode
                    :compile "rspec-mode.el")))

(el-get)

(provide 'mqt-el-get)
