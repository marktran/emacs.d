;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/functions.el : Mark Tran <mark@nirv.net>

;; copy n lines to the kill-ring
(defun copy-line (arg)
  "Copy N lines at point to the kill-ring"
  (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

(global-set-key "\C-cl" 'copy-line)

;;
(defun autocompile nil
  "Compile itself if ~/.emacs"
  (interactive)
  (require 'bytecomp)
  (let ((dotemacs (expand-file-name "~/.emacs")))
    (if (string= (buffer-file-name) (file-chase-links dotemacs))
      (byte-compile-file dotemacs))))

(add-hook 'after-save-hook 'autocompile)

;;
(defun show-linum-and-goto nil
  "Temporarily enable linum-mode then jump to specified line"
  (interactive)
  (fringe-mode 'default)
  (linum-mode 1)
  (goto-line (read-number "Goto Line: "))
  (linum-mode -1)
  (fringe-mode '(0 . right-only)))

(global-set-key "\M-g\M-g" 'show-linum-and-goto)

;;
(defun kmacro-start-or-end (arg)
  "Toggle recording of keyboard macro"
  (interactive "P")
  (if defining-kbd-macro
      (kmacro-end-macro arg)
    (kmacro-start-macro arg)))

(global-set-key [(shift f4)] 'kmacro-start-or-end)

;; smart tab
(defvar smart-tab-using-hippie-expand nil
  "turn this on if you want to use hippie-expand completion.")

(defun smart-tab (prefix)
  "Needs `transient-mark-mode' to be on. This smart tab is
minibuffer compliant: it acts as usual in the minibuffer.

In all other buffers: if PREFIX is \\[universal-argument], calls
`smart-indent'. Else if point is at the end of a symbol,
expands it. Else calls `smart-indent'."
  (interactive "P")
  (if (minibufferp)
      (minibuffer-complete)
    (if (smart-tab-must-expand prefix)
        (if smart-tab-using-hippie-expand
            (hippie-expand nil)
          (dabbrev-expand nil))
      (smart-indent))))

(defun smart-indent ()
  "Indents region if mark is active, or current line otherwise."
  (interactive)
  (if mark-active
      (indent-region (region-beginning)
                     (region-end))
    (indent-for-tab-command)))

(defun smart-tab-must-expand (&optional prefix)
  "If PREFIX is \\[universal-argument], answers no.
Otherwise, analyses point position and answers."
  (unless (or (consp prefix)
              mark-active)
    (looking-at "\\_>")))

(global-set-key [(tab)] 'smart-tab)

;;
(provide 'functions)
