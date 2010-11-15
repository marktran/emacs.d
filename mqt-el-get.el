;;; note: on the initial (el-get), if magit is not installed, el-get will
;;;       error because the "git" executable cannot be found.

(require 'el-get)

(setq el-get-sources
      '(autopair color-theme el-get magit package smex switch-window textile-mode undo-tree
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
                 (:name slime :type elpa)
                 (:name textmate :type elpa)
                 (:name yaml-mode :type elpa)

                 (:name color-theme-chocolate-rain
                        :type git
                        :url "git://github.com/marktran/color-theme-chocolate-rain.git"
                        :load "color-theme-chocolate-rain.el"
                        :after (lambda () (color-theme-chocolate-rain)))))

(el-get)

(provide 'mqt-el-get)
