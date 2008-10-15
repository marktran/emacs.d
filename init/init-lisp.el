;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-lisp.el : Mark Tran <mark@nirv.net>

(add-to-list 'load-path "~/lib/lisp/clbuild/source/slime")

(require 'slime-autoloads)
(add-hook 'lisp-mode-hook (lambda ()
                            (cond ((not (featurep 'slime))
                                   (require 'slime)
                                   (normal-mode)))))
(add-hook 'lisp-mode-hook (lambda () (paredit-mode +1)))

(setq slime-lisp-implementations '((sbcl ("sbcl"))))

(eval-after-load 'slime
  '(progn
    (add-to-list 'load-path "~/lib/lisp/clbuild/source/slime/contrib")
    (slime-setup
     '(slime-asdf
       slime-autodoc
       slime-fancy
       slime-references
       slime-scratch))
    (setq slime-complete-symbol*-fancy t)
    (setq slime-complete-symbol-function 'slime-fuzzy-complete-symbol)

    (define-key slime-mode-map (kbd "TAB") 'slime-indent-and-complete-symbol)
    (define-key slime-mode-map (kbd "C-c TAB") 'slime-complete-form)))

;; C-h S (info-lookup-symbol) to view HyperSpec entry
;; http://www.phys.au.dk/~harder/dpans.html
(require 'info-look)
(info-lookup-add-help
 :mode 'lisp-mode
 :regexp "[^][()'\" \t\n]+"
 :ignore-case t
 :doc-spec '(("(ansicl)Symbol Index" nil nil nil)))

(provide 'init-lisp)
