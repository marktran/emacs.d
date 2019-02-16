(use-package typescript-mode
  :hook ((typescript-mode . typescript/fmt-before-save-hook))
  :init
  (setq typescript-indent-level 2))

(use-package tide
  :after typescript-mode company flycheck
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(defvar typescript-fmt-tool 'tide
  "The name of the tool to be used
for TypeScript source code formatting.
Currently avaliable 'tide (default)
and 'typescript-formatter .")

(defun typescript/tsfmt-format-buffer ()
  "Format buffer with tsfmt."
  (interactive)
  (if (executable-find "tsfmt")
      (let*  ((tmpfile (make-temp-file "~fmt-tmp" nil ".ts"))
              (coding-system-for-read 'utf-8)
              (coding-system-for-write 'utf-8)
              (outputbuf (get-buffer-create "*~fmt-tmp.ts*")))
        (unwind-protect
            (progn
              (with-current-buffer outputbuf (erase-buffer))
              (write-region nil nil tmpfile)
              (if (zerop (apply 'call-process "tsfmt" nil outputbuf nil
                                (list (format
                                       "--baseDir='%s' --"
                                       default-directory)
                                      tmpfile)))
                  (let ((p (point)))
                    (save-excursion
                      (with-current-buffer (current-buffer)
                        (erase-buffer)
                        (insert-buffer-substring outputbuf)))
                    (goto-char p)
                    (message "formatted.")
                    (kill-buffer outputbuf))
                (progn
                  (message "Formatting failed!")
                  (display-buffer outputbuf)))
              (progn
                (delete-file tmpfile)))))
    (error "tsfmt not found. Run \"npm install -g typescript-formatter\"")))

(defun typescript/format ()
  "Call formatting tool specified in `typescript-fmt-tool'."
  (interactive)
  (cond
   ((eq typescript-fmt-tool 'typescript-formatter)
    (call-interactively 'typescript/tsfmt-format-buffer))
   ((eq typescript-fmt-tool 'tide)
    (call-interactively 'tide-format))
   (t (error (concat "%s isn't valid typescript-fmt-tool value."
                     " It should be 'tide or 'typescript-formatter."
                     (symbol-name typescript-fmt-tool))))))
