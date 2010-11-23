;;; note: on the initial (el-get), if magit is not installed and "git" is not
;;;       in your $PATH (remember, Emacs.app does not inherit environment
;;;       variables), el-get will error.

(require 'el-get)

(setq el-get-sources
      '(apel autopair color-theme django-mode el-get emacs-w3m magit nxhtml
             package pymacs python-mode slime smex switch-window textile-mode
             undo-tree yasnippet
             
             ;; elpa
             (:name clojure-mode :type elpa)
             (:name dired-isearch :type elpa)
             (:name full-ack :type elpa)
             (:name gist :type elpa)
             (:name haml-mode :type elpa)
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
             (:name sass-mode :type elpa)
             (:name Save-visited-files :type elpa)
             (:name textmate :type elpa)
             (:name yaml-mode :type elpa)

             ;; emacswiki
             (:name browse-kill-ring :type emacswiki)
             (:name dired+ :type emacswiki)

             ;; other
             (:name coffee-mode
                    :type git
                    :url "git://github.com/defunkt/coffee-mode.git")
             (:name color-theme-chocolate-rain
                    :type git
                    :url "git://github.com/marktran/color-theme-chocolate-rain.git"
                    :load "color-theme-chocolate-rain.el"
                    :after (lambda () (color-theme-chocolate-rain)))
             (:name diminish
                    :type http
                    :url "http://www.eskimo.com/~seldon/diminish.el")
             (:name growl
                    :type http
                    :url "http://edward.oconnor.cx/elisp/growl.el")
             (:name ipython
                    :type http
                    :url "http://ipython.scipy.org/dist/ipython.el")
             (:name markdown-mode
                    :type git
                    :url "git://jblevins.org/git/markdown-mode.git")
             (:name mo-git-blame
                    :type git
                    :url "git://github.com/voins/mo-git-blame.git")
             (:name mode-compile
                    :type http
                    :url "http://perso.tls.cena.fr/boubaker/distrib/mode-compile.el")
             (:name paredit
                    :type http
                    :url "http://mumble.net/~campbell/emacs/paredit.el")
             (:name peepopen
                    :type git
                    :url "git://github.com/topfunky/PeepOpen-EditorSupport.git"
                    :features peepopen)
             (:name quack
                    :type http
                    :url "http://www.neilvandyke.org/quack/quack.el")
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
