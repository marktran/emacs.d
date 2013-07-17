;; https://github.com/bbatsov/prelude/blob/master/core/prelude-editor.el
(defun save-modified-buffer ()
  "Save the current buffer if `prelude-auto-save' is not nil."
  (when (and buffer-file-name
             (buffer-modified-p (current-buffer))
             (file-writable-p buffer-file-name))
    (save-buffer)))

(advise-commands "auto-save"
                 (switch-to-buffer
                  other-window
                  windmove-up
                  windmove-down
                  windmove-left
                  windmove-right)
                 (save-modified-buffer))
