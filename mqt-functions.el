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

;; http://atomized.org/2009/05/emacs-23-easier-directory-local-variables/
(defmacro absolute-dirname (path)
  "Return the directory name portion of a path.

If PATH is local, return it unaltered.
If PATH is remote, return the remote diretory portion of the path."
  `(cond ((tramp-tramp-file-p ,path)
          (elt (tramp-dissect-file-name ,path) 3))
         (t ,path)))

(defmacro dir-locals (dir vars)
  "Set local variables for a directory.

DIR is the base diretory to set variables on.

VARS is an alist of variables to set on files opened under DIR,
in the same format as `dir-locals-set-class-variables' expects."
  `(let ((name (intern (concat "dir-locals-"
                               ,(md5 (expand-file-name dir)))))
         (base-dir ,dir)
         (base-abs-dir ,(absolute-dirname dir)))
     (dir-locals-set-class-variables name ,vars)
     (dir-locals-set-directory-class ,dir name nil)))

(defmacro dir-locals-safe (directory variables)
  "Set local variables for a directory and add variables to 
safe-local-variable-values."
  `(progn
     (dir-locals ,directory ,variables)
     (dolist (class ,variables)
       (dolist (variable (cdr class))
         (add-to-list 'safe-local-variable-values variable)))))

;; http://www.emacswiki.org/emacs/AutoPairs#toc8
(setq skeleton-pair t
      skeleton-pair-alist
      '((?\( _ ?\))
        (?[  _ ?])
        (?{  _ ?})
        (?\" _ ?\")))

(defun autopair-insert (arg)
  (interactive "P")
  (let (pair)
    (cond
     ((assq last-command-char skeleton-pair-alist)
      (autopair-open arg))
     (t
      (autopair-close arg)))))

(defun autopair-open (arg)
  (interactive "P")
  (let ((pair (assq last-command-char
                    skeleton-pair-alist)))
    (cond
     ((and (not mark-active)
           (eq (car pair) (car (last pair)))
           (eq (car pair) (char-after)))
      (autopair-close arg))
     (t
      (skeleton-pair-insert-maybe arg)))))

(defun autopair-close (arg)
  (interactive "P")
  (cond
   (mark-active
    (let (pair open)
      (dolist (pair skeleton-pair-alist)
        (when (eq last-command-char (car (last pair)))
          (setq open (car pair))))
      (setq last-command-char open)
      (skeleton-pair-insert-maybe arg)))
   ((looking-at
     (concat "[ \t\n]*"
             (regexp-quote (string last-command-char))))
    (replace-match (string last-command-char))
    (indent-according-to-mode))
   (t
    (self-insert-command (prefix-numeric-value arg))
    (indent-according-to-mode))))

(defadvice delete-backward-char (before autopair activate)
  (when (and (char-after)
             (eq this-command 'delete-backward-char)
             (eq (char-after)
                 (car (last (assq (char-before) skeleton-pair-alist)))))
    (delete-char 1)))

;; (global-set-key "("  'autopair-insert)
;; (global-set-key ")"  'autopair-insert)
;; (global-set-key "["  'autopair-insert)
;; (global-set-key "]"  'autopair-insert)
;; (global-set-key "{"  'autopair-insert)
;; (global-set-key "}"  'autopair-insert)
;; (global-set-key "\"" 'autopair-insert)

;; using IDO for bookmarks and recent files
;; http://blog.kelsin.net/2010/04/22/using-ido-for-bookmarks-and-recent-files/
(defun bookmark-ido-find-file ()
  "Find a bookmark using Ido."
  (interactive)
  (let ((bm (ido-completing-read "Open Bookmark: "
                                 (bookmark-all-names)
                                 nil t)))
    (when bm
      (bookmark-jump bm))))

;; calculate rows/columns based on resolution
(defconst display-padding '(100 50)
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

;; https://github.com/technomancy/emacs-starter-kit/blob/master/starter-kit-defuns.el
(defun add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))

(add-hook 'coding-hook 'add-watchwords)

(defun run-coding-hook ()
  "Enable things that are convenient across all coding buffers."
  (run-hooks 'coding-hook))

;; http://www.emacswiki.org/emacs/CommentingCode
(defun comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command.
If no region is selected and current line is not blank and we are not at the
end of the line, then comment current line. Replaces default behaviour of
comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position)
                                   (line-end-position))
    (comment-dwim arg)))

;; ido complete everything
;; http://www.emacswiki.org/emacs/InteractivelyDoThings#toc13
(defvar ido-enable-replace-completing-read t
  "If t, use ido-completing-read instead of completing-read if possible.
    
    Set it to nil using let in around-advice for functions where the
    original completing-read is required.  For example, if a function
    foo absolutely must use the original completing-read, define some
    advice like this:
    
    (defadvice foo (around original-completing-read-only activate)
      (let (ido-enable-replace-completing-read) ad-do-it))")

;; Replace completing-read wherever possible, unless directed otherwise
(defadvice completing-read
  (around use-ido-when-possible activate)
  (if (or (not ido-enable-replace-completing-read) ; Manual override disable ido
          (and (boundp 'ido-cur-list)
               ido-cur-list)) ; Avoid infinite loop from ido calling this
      ad-do-it
    (let ((allcomp (all-completions "" collection predicate)))
      (if allcomp
          (setq ad-return-value
                (ido-completing-read prompt
                                     allcomp
                                     nil require-match initial-input hist def))
        ad-do-it))))

;; http://article.gmane.org/gmane.emacs.help/69021
(defmacro elscreen-create-automatically (ad-do-it)
  `(if (not (elscreen-one-screen-p))
       ,ad-do-it
     (elscreen-create)
     (elscreen-notify-screen-modification 'force-immediately)
     (elscreen-message "New screen is automatically created")))

(defadvice elscreen-jump (before elscreen-jump-create activate)
  (let ((next-screen (string-to-number (string last-command-event))))
    (when (and (<= 0 next-screen)
               (<= next-screen 9)
               (not (elscreen-screen-live-p next-screen)))
      (elscreen-set-window-configuration
       (elscreen-get-current-screen)
       (elscreen-current-window-configuration))
      (elscreen-set-window-configuration
       next-screen (elscreen-default-window-configuration))
      (elscreen-append-screen-to-history next-screen)
      (elscreen-notify-screen-modification 'force))))

(defadvice elscreen-next (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))

(defadvice elscreen-previous (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))

(defadvice elscreen-toggle (around elscreen-create-automatically activate)
  (elscreen-create-automatically ad-do-it))

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

;; http://www.emacswiki.org/emacs/InteractivelyDoThings#toc4
(defun ido-erc-buffer ()
  (interactive)
  (switch-to-buffer
   (ido-completing-read "Channel: "
                        (save-excursion
                          (delq
                           nil
                           (mapcar (lambda (buf)
                                     (when (buffer-live-p buf)
                                       (with-current-buffer buf
                                         (and (eq major-mode 'erc-mode)
                                              (buffer-name buf)))))
                                   (buffer-list)))))))

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
                               (setq position
                                     (get-text-property 1
                                                        'org-imenu-marker
                                                        symbol))))

                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos
                                            (cons name position))))))))
      (addsymbols imenu--index-alist))
    (let* ((selected-symbol (ido-completing-read "Symbol: " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (cond
       ((overlayp position)
        (goto-char (overlay-start position)))
       (t
        (goto-char position))))))

;; http://blog.jrock.us/articles/Increment%20test%20counter.pod
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

;; http://www.emacswiki.org/emacs/SearchAtPoint#toc5
(defun isearch-yank-symbol ()
  "*Put symbol at current point into search string."
  (interactive)
  (let ((sym (symbol-at-point)))
    (if sym
        (progn
          (setq isearch-regexp t
                isearch-string (concat "\\_<"
                                       (regexp-quote (symbol-name sym)) "\\_>")
                isearch-message (mapconcat 'isearch-text-char-description
                                           isearch-string "")
                isearch-yank-flag t))
      (ding)))
  (isearch-search-and-update))

;; http://blog.tuxicity.se/elisp/emacs/2010/11/16/delete-file-and-buffer-in-emacs.html
(defun kill-buffer-and-delete-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

;; http://www.emacswiki.org/emacs/SlickCopy
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;; http://www.emacswiki.org/emacs/RecreateScratchBuffer
(save-excursion
  (set-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode)
  (paredit-mode)
  (make-local-variable 'kill-buffer-query-functions)
  (add-hook 'kill-buffer-query-functions 'kill-scratch-buffer))

(defun kill-scratch-buffer ()
  ;; The next line is just in case someone calls this manually
  (set-buffer (get-buffer-create "*scratch*"))
  ;; Kill the current (*scratch*) buffer
  (remove-hook 'kill-buffer-query-functions 'kill-scratch-buffer)
  (kill-buffer (current-buffer))
  ;; Make a brand new *scratch* buffer
  (set-buffer (get-buffer-create "*scratch*"))
  (lisp-interaction-mode)
  (make-local-variable 'kill-buffer-query-functions)
  (add-hook 'kill-buffer-query-functions 'kill-scratch-buffer)
  ;; Since we killed it, don't let caller do that.
  nil)

;;
(defun kmacro-start-or-end (arg)
  "Toggle recording of keyboard macro."
  (interactive "P")
  (if defining-kbd-macro
      (kmacro-end-macro arg)
    (kmacro-start-macro arg)))

;; http://www.emacswiki.org/emacs-es/RecentFiles#toc7
(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let* ((file-assoc-list
          (mapcar (lambda (x)
                    (cons (file-name-nondirectory x)
                          x))
                  recentf-list))
         (filename-list
          (remove-duplicates (mapcar #'car file-assoc-list)
                             :test #'string=))
         (filename (ido-completing-read "Recent file: "
					filename-list
					nil
					t)))
    (when filename
      (find-file (cdr (assoc filename
                             file-assoc-list))))))

;; http://blog.plover.com/prog/revert-all.html
(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files"
  (interactive)
  (let* ((list (buffer-list))
         (buffer (car list)))
    (while buffer
      (when (and (buffer-file-name buffer) 
                 (not (buffer-modified-p buffer)))
        (set-buffer buffer)
        (revert-buffer t t t))
      (setq list (cdr list))
      (setq buffer (car list))))
  (message "Refreshed open files"))

;; http://atomized.org/2010/06/ \
;; resolving-merge-conflicts-the-easy-way-with-smerge-kmacro/
(defun sm-try-smerge ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^<<<<<<< " nil t)
      (smerge-mode 1))))

(add-hook 'find-file-hook 'sm-try-smerge t)

;; http://atomized.org/2008/10/enhancing-emacs%E2%80%99-sql-mode/
(defun sql-make-smart-buffer-name ()
  "Return a string that can be used to rename a SQLi buffer.

This is used to set `sql-alternate-buffer-name' within
`sql-interactive-mode'."
  (or (and (boundp 'sql-name) sql-name)
      (concat (if (not(string= "" sql-server))
                  (concat
                   (or (and (string-match "[0-9.]+" sql-server) sql-server)
                       (car (split-string sql-server "\\.")))
                   "/"))
              sql-database)))


(add-hook 'sql-interactive-mode-hook
          (lambda ()
            (setq sql-alternate-buffer-name (sql-make-smart-buffer-name))
            (sql-rename-buffer)))

(defun sql-connect-preset (name)
  "Connect to a predefined SQL connection listed in `sql-connection-alist'"
  (eval `(let ,(cdr (assoc name sql-connection-alist))
           (flet ((sql-get-login (&rest what)))
             (sql-product-interactive sql-product)))))

;; http://github.com/technomancy/emacs-starter-kit/blob/master/\
;; starter-kit-defuns.el
(defun switch-or-start (function buffer)
  "If the buffer is current, bury it, otherwise invoke the function."
  (if (equal (buffer-name (current-buffer)) buffer)
      (bury-buffer)
    (if (get-buffer buffer)
        (switch-to-buffer buffer)
      (funcall function))))

;; http://www.emacswiki.org/emacs/TransposeWindows
(defun transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(provide 'mqt-functions)
