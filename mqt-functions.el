;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-functions.el : Mark Tran <mark@nirv.net>

;; auto indentation for pasted lines
;; http://www.emacswiki.org/emacs/AutoIndentation
(dolist (command '(yank yank-pop))
  (eval `(defadvice ,command (after indent-region activate)
           (and (not current-prefix-arg)
                (member major-mode '(emacs-lisp-mode lisp-mode
                                                     clojure-mode   scheme-mode
                                                     haskell-mode   ruby-mode
                                                     rspec-mode     python-mode
                                                     c-mode         c++-mode
                                                     objc-mode      latex-mode
                                                     plain-tex-mode))
                (let ((mark-even-if-inactive transient-mark-mode))
                  (indent-region (region-beginning) (region-end) nil))))))

;; calculate rows/columns based on resolution
(defconst display-padding '(150 50)
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
            scroll-bar dock-width)
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

;; http://www.emacswiki.org/emacs/CommentingCode
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and we are not at the 
end of the line, then comment current line. Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

;;
(defun copy-line (arg)
  "Copy N lines at point to the kill-ring"
  (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

;; highlight HTML-style color strings in the color they specify
(defvar hexcolor-keywords
  '(("#[ABCDEFabcdef[:digit:]]\\{6\\}"
     (0 (put-text-property
         (match-beginning 0)
         (match-end 0)
         'face (list :background
                     (match-string-no-properties 0)))))))

(defun hexcolor-add-to-font-lock ()
  (interactive)
  (font-lock-add-keywords nil hexcolor-keywords))

;; http://www.emacswiki.org/emacs/ImenuMode#toc10
(defun ido-goto-symbol ()
  "Update the imenu index and then use ido to select a symbol to navigate to"
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))
                              
                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))
                              
                              ((stringp symbol)
                               (setq name symbol)
                               (setq position (get-text-property 1 'org-imenu-marker symbol))))
                             
                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    (let* ((selected-symbol (ido-completing-read "Symbol: " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (cond
       ((overlayp position)
        (goto-char (overlay-start position)))
       (t
        (goto-char position))))))

;;
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

;;
(defun kmacro-start-or-end (arg)
  "Toggle recording of keyboard macro"
  (interactive "P")
  (if defining-kbd-macro
      (kmacro-end-macro arg)
    (kmacro-start-macro arg)))

;;
(defvar smart-tab-using-hippie-expand t
  "turn this on if you want to use hippie-expand completion.")

(setq hippie-expand-try-functions-list
      '(yas/hippie-try-expand
        try-expand-dabbrev
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

;;
(defun switch-to-scratch-or-previous ()
  "switch-to *scratch* or previous buffer"
  (interactive)
  (if (string-match (buffer-name (current-buffer)) "*scratch*")
      (switch-to-buffer (other-buffer))
    (switch-to-buffer "*scratch*")))

;;
(defun switch-or-start (function buffer)
  "If the buffer is current, bury it, otherwise invoke the function."
  (if (equal (buffer-name (current-buffer)) buffer)
      (bury-buffer)
    (if (get-buffer buffer)
        (switch-to-buffer buffer)
      (funcall function))))

(provide 'mqt-functions)
