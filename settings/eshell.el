(defun host-name ()
  "Returns the name of the current host minus the domain."
  (let ((hostname (downcase (system-name))))
    (save-match-data
      (substring hostname (string-match "^[^.]+" hostname) (match-end 0)))))

(setq eshell-aliases-file "~/.emacs.d/eshell/alias"
      eshell-banner-message ""
      eshell-cmpl-cycle-completions nil
      eshell-cmpl-dir-ignore "\\`\\(\\.\\.?\\|CVS\\|\\.svn\\|\\.git\\)/\\'"
      eshell-highlight-prompt nil
      eshell-last-dir-ring-size 10
      eshell-list-files-after-cd t
      eshell-prompt-function
      (lambda ()
        (concat
         (propertize (host-name) 'face `(:foreground "#cf6a4c"))
         " "
         (propertize (abbreviate-file-name (eshell/pwd)) 'face `(:foreground "#cd00cd"))
         " "))
      eshell-prompt-regexp "^[^@]*@[^ ]* [^ ]* ")
