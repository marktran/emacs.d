(use-package elisp-mode
  :ensure nil

  :preface
  (defun m/emacs-lisp-setup ()
    (setq-local mode-name "ELisp")
    (setq-local sentence-end-double-space nil))

  :hook
  ((emacs-lisp-mode . show-paren-mode)
   (emacs-lisp-mode . m/emacs-lisp-setup))

  :general
  (:keymaps 'emacs-lisp-mode-map
   :states 'normal
   :prefix "SPC ,"
   "" '(:ignore t :which-key "ELisp")
   "b" '(eval-buffer :which-key "Eval buffer")
   "d" '(eval-defun :which-key "Eval defun")
   "e" '(eval-last-sexp :which-key "Eval sexp before point")
   "r" '(eval-region :which-key "Eval region")))

(use-package paredit
  :ensure t
  :diminish paredit-mode

  :hook
  ((emacs-lisp-mode . paredit-mode)
   (lisp-interaction-mode . paredit-mode)
   (lisp-mode . paredit-mode)
   (scheme-mode . paredit-mode)
   (slime-repl-mode . paredit-mode)))

(defvar calculate-lisp-indent-last-sexp) ; dynamically bound in `calculate-lisp-indent'

(defun m/lisp-indent-function (indent-point state)
  "Like `lisp-indent-function', but indent keyword lists sanely.

Instead of the default

  (:foo bar
        :baz qux)

keyword lists are indented as

  (:foo bar
   :baz qux)

INDENT-POINT is the position at which the line being indented begins.
STATE is the `parse-partial-sexp' state for that position.

Adapted from URL
`https://github.com/Fuco1/.emacs.d/blob/master/site-lisp/my-redef.el'."
  (let ((normal-indent (current-column))
        (orig-point (point)))
    (goto-char (1+ (elt state 1)))
    (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
    (cond
     ;; car of form doesn't seem to be a symbol, or is a keyword
     ((and (elt state 2)
           (or (not (looking-at "\\sw\\|\\s_"))
               (looking-at ":")))
      (unless (> (save-excursion (forward-line 1) (point))
                 calculate-lisp-indent-last-sexp)
        (goto-char calculate-lisp-indent-last-sexp)
        (beginning-of-line)
        (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t))
      ;; Indent under the list or under the first sexp on the same
      ;; line as calculate-lisp-indent-last-sexp.  Note that first
      ;; thing on that line has to be complete sexp since we are
      ;; inside the innermost containing sexp.
      (backward-prefix-chars)
      (current-column))
     ((and (save-excursion
             (goto-char indent-point)
             (skip-syntax-forward " ")
             (not (looking-at ":")))
           (save-excursion
             (goto-char orig-point)
             (looking-at ":")))
      (save-excursion
        (goto-char (+ 2 (elt state 1)))
        (current-column)))
     (t
      (let* ((function (buffer-substring (point)
                                         (progn (forward-sexp 1) (point))))
             (method (or (function-get (intern-soft function)
                                       'lisp-indent-function)
                         (get (intern-soft function) 'lisp-indent-hook))))
        (cond ((or (eq method 'defun)
                   (and (null method)
                        (> (length function) 3)
                        (string-match "\\`def" function)))
               (lisp-indent-defform state indent-point))
              ((integerp method)
               (lisp-indent-specform method state
                                     indent-point normal-indent))
              (method
               (funcall method indent-point state))))))))

(setq-default lisp-indent-function #'m/lisp-indent-function)
