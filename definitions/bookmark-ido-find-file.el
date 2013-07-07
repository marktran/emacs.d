;; http://blog.kelsin.net/2010/04/22/using-ido-for-bookmarks-and-recent-files/
(defun bookmark-ido-find-file ()
  "Find a bookmark using Ido."
  (interactive)
  (let ((bm (ido-completing-read "Open Bookmark: "
                                 (bookmark-all-names)
                                 nil t)))
    (when bm
      (bookmark-jump bm))))
