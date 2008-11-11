;;; -*- Mode: Emacs-Lisp; -*-

;;; .gnus : Mark Tran <mark@nirv.net>

(setq user-full-name "Mark Tran"
      user-mail-address "mark@nirv.net")

(setq gnus-select-method
      '(nntp "news.csh.rit.edu"
             (nntp-address "news.csh.rit.edu")
             (nntp-port-number 119))
      nntp-authinfo-file "~/.netrc")

(setq gnus-secondary-select-methods
      '((nntp "news.gmane.org"
              (nntp-address "news.gmane.org")
              (nntp-port-number 119))))

(setq gnus-inhibit-startup-message t
      gnus-interactive-exit nil
      gnus-mode-line-image-cache nil
      gnus-novice-user nil
      gnus-summary-display-arrow nil
      gnus-summary-dummy-line-format ""
      gnus-summary-line-format "%U%R%z %d %-20,20n %B%s\n"
      gnus-summary-mode-line-format "%g [%A / %z] %Z"
      gnus-treat-display-smileys nil
      gnus-use-cache 'passive
      gnus-use-full-window nil
      message-from-style 'angles)

(add-hook 'message-mode-hook
          '(lambda ()
            (turn-on-auto-fill)
            (setq fill-column 72)))

;; scoring
(setq gnus-use-adaptive-scoring t
      gnus-default-adaptive-score-alist
      '((gnus-unread-mark)
        (gnus-ticked-mark (subject 5)) 
        (gnus-read-mark (subject 1)) 
        (gnus-catchup-mark (subject -1)) 
        (gnus-killed-mark (subject -5))))

(add-hook 'message-sent-hook 'gnus-score-followup-article)

;; gnus sync
(setq gnussync-remote "lambda.nirv.net")
(setq gnussync-remote-login "tran")
(setq gnussync-rsync-binary "/usr/bin/rsync")
(setq gnussync-rsync-options "-auRvzp --delete")
(setq gnussync-extra-files "~/.gnus.d/")

(defun gnussync-sync (arg)
  (interactive)
  (let ((filelist 
	 (append  
	  (list
	   gnus-startup-file
	   (format "%s.eld" gnus-startup-file)
	   (directory-file-name gnus-directory)
	   (directory-file-name message-directory))
	  gnussync-extra-files))
	(bufname (get-buffer-create "*GNUS SYNC*")))
    (cond 
     ((and (eq arg 'to-remote)
	  (y-or-n-p (format "Sync Gnus files to %s? " gnussync-remote)))
      (switch-to-buffer bufname)
      (insert "\n\n === LOCAL  -->  REMOTE ===\n")
      (apply 'call-process 
	     gnussync-rsync-binary 
	     (append 
	      (list nil bufname t)
	      (split-string gnussync-rsync-options)
	      (mapcar (lambda (file)
		    (if (string-match "^~" file)
		      (replace-match (format "%s/." (getenv "HOME")) t t file)
		      file))
		      filelist)
	      (list (format "%s@%s:" gnussync-remote-login gnussync-remote)))))
     ((and (eq arg 'from-remote)
	   (y-or-n-p (format "Sync Gnus files from %s? " gnussync-remote)))
      (switch-to-buffer bufname)
      (insert "\n\n === REMOTE  -->  LOCAL ===\n")
      (apply 'call-process 
	     gnussync-rsync-binary 
	     (append
	      (list nil bufname t)
	      (split-string gnussync-rsync-options " ")
	      (list (format "%s@%s:%s" gnussync-remote-login gnussync-remote 
			    (mapconcat 
			     (lambda (file)
			       (if (string-match "^~/" file)
				   (replace-match "" t t file)
				 file))
			     filelist " "))
		    (expand-file-name "~"))))))))

(add-hook 'gnus-before-startup-hook (lambda () (gnussync-sync 'from-remote)))
(add-hook 'gnus-after-exiting-gnus-hook (lambda () (gnussync-sync 'to-remote)))

;; gnus demon
(gnus-demon-add-handler 'gnus-demon-scan-news 30 t)
(gnus-demon-init)

(gnus-compile)
