(require-package 'emmet-mode)

(setq emmet-indentation 2
      emmet-preview-default nil)

(after-load 'emmet-mode
  (define-key emmet-mode-keymap (kbd "<backtab>") 'emmet-expand-line)
  (define-key emmet-mode-keymap (kbd "C-j") nil))
