(defun dwim-helm-find-files-navigate-forward (orig-fun &rest args)
  "Adjust how helm-execute-persistent actions behaves, depending on context"
  (if (file-directory-p (helm-get-selection))
      (apply orig-fun args)
    (helm-maybe-exit-minibuffer)))
