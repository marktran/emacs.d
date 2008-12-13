;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-lisp.el : Mark Tran <mark@nirv.net>

(add-to-list 'load-path "~/lib/lisp/clbuild/source/slime")
(add-to-list 'load-path "~/lib/lisp/clbuild/source/slime/contrib")

(set-language-environment "UTF-8")
(setq inferior-lisp-program "~/lib/lisp/clbuild/clbuild 
--implementation sbcl preloaded"
      slime-backend "~/lib/lisp/clbuild/.swank-loader.lisp"
      slime-net-coding-system 'utf-8-unix)

(require 'slime-autoloads)
(add-hook 'lisp-mode-hook (lambda ()
                            (cond ((not (featurep 'slime))
                                   (require 'slime)
                                   (normal-mode)))))
(add-hook 'lisp-mode-hook (lambda () (paredit-mode +1)))

(eval-after-load 'slime
  '(progn
     (slime-setup
      '(slime-asdf
        slime-autodoc
        slime-fancy
        slime-references
        slime-scratch
        slime-tramp))

     (setq slime-complete-symbol*-fancy t
           slime-complete-symbol-function 'slime-fuzzy-complete-symbol
           slime-lisp-implementations '((sbcl ("sbcl"))))

     (define-key slime-mode-map (kbd "TAB") 'slime-indent-and-complete-symbol)
     (define-key slime-mode-map (kbd "C-c TAB") 'slime-complete-form)))

;; redshank
(require 'redshank-loader "~/lib/lisp/clbuild/source/redshank/redshank-loader.el")

(eval-after-load "redshank-loader"
  `(redshank-setup '(lisp-mode-hook
                     slime-repl-mode-hook) t))

;; C-h S (info-lookup-symbol) to view HyperSpec entry
;; http://www.phys.au.dk/~harder/dpans.html
(autoload 'info-lookup-symbol "info-look" "Lookup documentation" t)
(eval-after-load 'info-look
  '(info-lookup-add-help
    :mode 'lisp-mode
    :regexp "[^][()'\" \t\n]+"
    :ignore-case t
    :doc-spec '(("(ansicl)Symbol Index" nil nil nil))))

(provide 'init-lisp)
