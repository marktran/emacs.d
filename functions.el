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

(defun host-name ()
  "Returns the name of the current host minus the domain."
  (let ((hostname (downcase (system-name))))
    (save-match-data
      (substring hostname (string-match "^[^.]+" hostname) (match-end 0)))))

;; http://www.emacswiki.org/emacs/TextMate
(defun ido-find-file-in-tag-files ()
  (interactive)
  (save-excursion
    (let ((enable-recursive-minibuffers t)) (visit-tags-table-buffer))
    (find-file (expand-file-name
                (ido-completing-read "Project file: "
                                     (tags-table-files) nil t)))))

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

;; http://whattheemacsd.com//file-defuns.el-01.html
(defun rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (if (get-buffer new-name)
            (error "A buffer named '%s' already exists!" new-name)
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message "File '%s' successfully renamed to '%s'"
                   name (file-name-nondirectory new-name)))))))

;; http://whattheemacsd.com//file-defuns.el-02.html
(defun delete-current-buffer-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))

;; https://github.com/technomancy/ido-ubiquitous/issues/3
(defadvice rgrep (around original-completing-read-only activate)
  (let (ido-ubiquitous-enabled) ad-do-it))

;; http://atomized.org/2010/06/ \
;; resolving-merge-conflicts-the-easy-way-with-smerge-kmacro/
(defun sm-try-smerge ()
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^<<<<<<< " nil t)
      (smerge-mode 1))))

(add-hook 'find-file-hook 'sm-try-smerge t)

;; https://github.com/cofi/dotfiles/blob/master/emacs.d/config/cofi-func.el
(defun fill-keymap (keymap &rest mappings)
  "Fill `KEYMAP' with `MAPPINGS'.
See `pour-mappings-to'."
  (pour-mappings-to keymap mappings))

(defmacro gen-fill-keymap-hook (keymap &rest mappings)
  "Build fun that fills `KEYMAP' with `MAPPINGS'.
See `pour-mappings-to'."
  `(lambda () (fill-keymap ,keymap ,@mappings)))

(defun pour-mappings-to (map mappings)
  "Calls `set-key' with `map' on every key-fun pair in `MAPPINGS'.
`MAPPINGS' is a list of string-fun pairs, with a `READ-KBD-MACRO'-readable string and a interactive-fun."
  (dolist (mapping (group mappings 2))
    (set-key map (car mapping) (cadr mapping)))
  map)

(defmacro cmd (&rest code)
  "Macro for shorter keybindings."
  `(lambda ()
     (interactive)
     ,@code))

(defun group (lst n)
  "Group `LST' into portions of `N'."
  (let (groups)
    (while lst
      (push (take n lst) groups)
      (setq lst (nthcdr n lst)))
    (nreverse groups)))

(defun take (n lst)
  "Return atmost the first `N' items of `LST'."
  (let (acc '())
    (while (and lst (> n 0))
      (decf n)
      (push (car lst) acc)
      (setq  lst (cdr lst)))
    (nreverse acc)))

(defun set-key (map spec cmd)
  "Set in `map' `spec' to `cmd'.

`Map' may be `'global' `'local' or a keymap.
A `spec' can be a `read-kbd-macro'-readable string or a vector."
  (let ((setter-fun (case map
                      (global #'global-set-key)
                      (local  #'local-set-key)
                      (t      (lambda (key def) (define-key map key def)))))
        (key (typecase spec
               (vector spec)
               (string (read-kbd-macro spec))
               (t (error "wrong argument")))))
    (funcall setter-fun key cmd)))

;; https://github.com/cofi/dotfiles/blob/master/emacs.d/config/cofi-windowing.el
(autoload 'windmove-find-other-window "windmove")
(defun swap-window (direction)
  "Swap current window with the one in `direction'."
  (interactive (list (ido-completing-read "Swap with window: "
                                          (mapcar 'symbol-name
                                                  '(left right down up)))))
  (let* ((dir (if (symbolp direction)
                  direction
                (intern direction)))
        (other-window (windmove-find-other-window dir)))
    (when other-window
      (let* ((this-window (selected-window))
             (this-buffer (window-buffer this-window))
             (other-buffer (window-buffer other-window))
             (this-start (window-start this-window))
             (other-start (window-start other-window)))
        (set-window-buffer this-window other-buffer)
        (set-window-buffer other-window this-buffer)
        (set-window-start this-window other-start)
        (set-window-start other-window this-start)))))

(defun swap-with-left () (interactive) (swap-window 'left))
(defun swap-with-down () (interactive) (swap-window 'down))
(defun swap-with-up () (interactive) (swap-window 'up))
(defun swap-with-right () (interactive) (swap-window 'right))

;; http://dfan.org/blog/2009/02/19/emacs-dedicated-windows/
(defun toggle-current-window-dedication ()
  (interactive)
  (let* ((window    (selected-window))
         (dedicated (window-dedicated-p window)))
    (set-window-dedicated-p window (not dedicated))
    (message "Window %sdedicated to %s"
             (if dedicated "no longer " "")
             (buffer-name))))
