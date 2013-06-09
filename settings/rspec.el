(setq rspec-compilation-buffer-name "*rspec-compilation*")

(defun rspec-recompile ()
  (interactive)
  (with-current-buffer rspec-compilation-buffer-name
    (recompile)))
