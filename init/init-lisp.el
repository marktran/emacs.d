;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-lisp.el : Mark Tran <mark@nirv.net>

(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((slime-dir "~/lib/lisp/clbuild/source/slime/")
           (default-directory slime-dir))
      (setq load-path (cons slime-dir load-path))
      (normal-top-level-add-subdirs-to-load-path)))

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
        slime-scratch))

     (setq slime-complete-symbol*-fancy t
           slime-complete-symbol-function 'slime-fuzzy-complete-symbol
           slime-lisp-implementations '((sbcl ("sbcl"))))

     (define-key slime-mode-map (kbd "TAB") 'slime-indent-and-complete-symbol)
     (define-key slime-mode-map (kbd "C-c TAB") 'slime-complete-form)))

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
