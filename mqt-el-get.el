;;; note: on the initial (el-get), if magit is not installed and "git" is not
;;;       in your $PATH (remember, Emacs.app does not inherit environment
;;;       variables), el-get will error.

(require 'el-get)

(setq el-get-sources
      '(apel autopair color-theme coffee-mode diminish dired+ django-mode
             el-get emacs-w3m haml-mode ipython magit markdown-mode
             mode-compile nxhtml package paredit pymacs python-mode quack
             sass-mode smart-tab smex switch-window textile-mode undo-tree
             yaml-mode yasnippet
             
             ;; elpa
             (:name clojure-mode :type elpa)
             (:name dired-isearch :type elpa)
             (:name gist :type elpa)
             (:name htmlize :type elpa)
             (:name inf-ruby :type elpa)
             (:name js2-mode :type elpa)
             (:name json :type elpa)
             (:name kill-ring-search :type elpa)
             (:name lua-mode :type elpa)
             (:name pastie :type elpa)
             (:name ruby-compilation :type elpa)
             (:name ruby-electric :type elpa)
             (:name ruby-mode :type elpa)
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
                    :url "http://edward.oconnor.cx/elisp/growl.el")
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
