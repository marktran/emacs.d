;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/init/init-functions.el : Mark Tran <mark@nirv.net>

;; calculate rows/columns based on resolution
(defconst display-padding '(50 50)
  "Amount of padding, in pixels, around the outside of the frame")

(defconst menubar-height 22
  "Magic Number. Menubar has a height of 22 pixels")

(defun calculate-columns (pixel-width)
  "Calculate available columns from the display pixel width"
  (let ((dock-width (string-to-number 
                      (shell-command-to-string 
                       "defaults read com.apple.dock tilesize")))
        (left-fringe (or left-fringe-width (nth 0 (window-fringes)) 0))
        (right-fringe (or right-fringe-width (nth 1 (window-fringes)) 0))
        (scroll-bar (or (frame-parameter nil 'scroll-bar-width) 0)))
      (/ (- pixel-width (nth 0 display-padding) left-fringe right-fringe
            scroll-bar)
      (frame-char-width))))

(defun calculate-rows (pixel-height)
  "Calculate available rows from the display pixel height"
  (/ (- pixel-height (nth 1 display-padding) menubar-height)
     (frame-char-height)))

(defun calculate-x-position (padding-width)
  "Calculate X offset from the display padding width"
  (/ padding-width 2))

(defun calculate-y-position (padding-height)
  "Calculate Y offset from the display padding height"
  (+ (/ padding-height 2) menubar-height))

;; copy n lines to the kill-ring
(defun copy-line (arg)
  "Copy N lines at point to the kill-ring"
  (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

;; increment number at point
(defun increment-number-at-point (&optional amount)
  "Increment the number under point by `amount'"
  (interactive "p")
  (let ((num (number-at-point)))
    (when (numberp num)
      (let ((newnum (+ num amount))
            (p (point)))
        (save-excursion
          (skip-chars-backward "-.0123456789")
          (delete-region (point) (+ (point) (length (number-to-string num))))
          (insert (number-to-string newnum)))
        (goto-char p)))))

;; start keyboard macro or end
(defun kmacro-start-or-end (arg)
  "Toggle recording of keyboard macro"
  (interactive "P")
  (if defining-kbd-macro
      (kmacro-end-macro arg)
    (kmacro-start-macro arg)))

;; smart tab
(defvar smart-tab-using-hippie-expand t
  "turn this on if you want to use hippie-expand completion.")

(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name
        try-complete-file-name-partially
        try-expand-list
        try-expand-line))

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

;; switch-to *scratch* or previous buffer
(defun switch-to-scratch-or-previous ()
  (interactive)
  (if (string-match (buffer-name (current-buffer)) "*scratch*")
      (switch-to-buffer (other-buffer))
    (switch-to-buffer "*scratch*")))

(provide 'init-functions)
