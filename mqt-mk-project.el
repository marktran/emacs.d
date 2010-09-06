;;; .emacs.d/mqt-mk-project.el : Mark Tran <mark@nirv.net>

(require 'mk-project)

;; key bindings
(global-set-key (kbd "C-t") 'project-find-file-ido)

;; project definitions
(project-def "cloudkick"
             '((basedir          "~/code/cloudkick/ck/webapp")
               (src-patterns     ("*.html" "*.py"))
               (ignore-patterns  ("*.png" "*.pyc" "*.swf" "*.txt"))
               (tags-file        "~/code/cloudkick/ck/webapp/.mk-project/TAGS")
               (file-list-cache  "~/code/cloudkick/ck/webapp/.mk-project/files")
               (open-files-cache "~/code/cloudkick/ck/webapp/.mk-project/open-files")
               (vcs              git)))

(provide 'mqt-mk-project)
