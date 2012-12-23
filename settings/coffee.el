(autoload 'coffee-mode "coffee-mode" nil t)

(dolist (mode '(("Cakefile" . coffee-mode)
                ("\\.coffee$" . coffee-mode)))
  (add-to-list 'auto-mode-alist mode))

;; coffee
(defun coffee-custom ()
  (set (make-local-variable 'tab-width) 2)
  (setq coffee-js-mode 'javascript-mode)

  (define-key coffee-mode-map [(meta r)] 'coffee-compile-buffer))

(add-hook 'coffee-mode-hook '(lambda() (coffee-custom)))


