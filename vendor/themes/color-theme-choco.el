;;; -*- Mode: Emacs-Lisp; -*-

;;; color-theme-choco.el : Mark Tran <mark@nirv.net>

(defun color-theme-choco ()
  "Choco theme"
  (interactive)
  (color-theme-install
   '(color-theme-choco
     ((foreground-color . "#c3be98")
      (background-color . "#1a0f0b")
      (border-color . "#c3be98")
      (cursor-color . "#a7a7a7"))
     (default ((t (nil))))
     (comint-highlight-input ((t (:foreground "#c3be98"))))
     (comint-highlight-prompt ((t (:foreground "#7989a6"))))
     (compilation-error ((t (:foreground "#d77261"))))
     (compilation-line-number ((t (:foreground "#7ca563"))))
     (css-property ((t (:foreground "#a18764"))))
     (css-selector ((t (:foreground "#7ca563"))))
     (dired-directory ((t (:foreground "#679d47"))))
     (dired-header ((t (:foreground "#b3935c"))))
     (erc-action-face ((t (:foreground "#d77261"))))
     (erc-button ((t (:foreground "#a8799c"))))
     (erc-current-nick-face ((t (:foreground "#da5659"))))
     (erc-error-face ((t (:foreground "#d77261"))))
     (erc-input-face ((t (:foreground "#c3be98"))))
     (erc-keyword-face ((t (:foreground "#cf6a4c"))))
     (erc-my-nick-face ((t (:foreground "#b3935c"))))
     (erc-nick-default-face ((t (:foreground "#c3be98"))))
     (erc-notice-face ((t (:foreground "#8a9a95"))))
     (erc-prompt-face ((t (:foreground "#8f9d6a"))))
     (erc-timestamp-face ((t (:foreground "#c3be98"))))
     (escape-glyph ((t (:foreground "#7989a6"))))
     (eshell-prompt ((t (:foreground "#c3be98"))))
     (flymake-errline ((t (:background "#1a0f0b"))))
     (font-lock-builtin-face ((t (:foreground "#b3935c"))))
     (font-lock-comment-face ((t (:italic t :foreground "#7ca563"))))
     (font-lock-constant-face ((t (:foreground "#da5659"))))
     (font-lock-doc-face ((t (:foreground "#a18764"))))
     (font-lock-function-name-face ((t (:foreground "#9b703f"))))
     (font-lock-keyword-face ((t (:foreground "#b3935c"))))
     (font-lock-preprocessor-face ((t (:foreground "#c3be98"))))
     (font-lock-string-face ((t (:foreground "#8f9d6a"))))
     (font-lock-type-face ((t (:foreground "#f1e694"))))
     (font-lock-variable-name-face ((t (:foreground "#8a9a95"))))
     (font-lock-warning-face ((t (:foreground "#da5659"))))
     (fringe ((t (:background "#1a0f0b"))))
     (gnus-button ((t (:foreground "#a8799c"))))
     (gnus-cite-1 ((t (:foreground "#7989a6"))))
     (gnus-cite-2 ((t (:foreground "#7989a6"))))
     (gnus-cite-attribution ((t (:foreground "#c3be98"))))
     (gnus-header-content ((t (:foreground "#a8799c"))))
     (gnus-header-name ((t (:foreground "#c3be98"))))
     (gnus-header-newsgroups ((t (:foreground "#983008"))))
     (gnus-header-subject ((t (:foreground "#a8799c"))))
     (gnus-summary-high-read ((t (:foreground "#679d47"))))
     (gnus-summary-high-unread ((t (:foreground "#d77261"))))
     (gnus-summary-normal-ancient ((t (:foreground "#7989a6"))))
     (gnus-summary-normal-read ((t (:foreground "#7ca563"))))
     (gnus-summary-selected ((t (:foreground "#a8799c"))))
     (header-line ((t (:foreground "#c3be98"))))
     (highlight ((t (:background "#483b39"))))
     (hl-line ((t (:background "#211612"))))
     (ido-first-match ((t (:foreground "#679d47"))))
     (ido-incomplete-regexp ((t (:foreground "#a5659"))))
     (ido-indicator ((t (:foreground "#7989a6"))))
     (ido-only-match ((t (:foreground "#679d47"))))
     (ido-subdir ((t (:foreground "#d35359"))))
     (info-header-node ((t (:foreground "#7ca563"))))
     (info-menu-star ((t (:foreground "#d77261"))))
     (info-xref ((t (:underline t :foreground "#7989a6"))))
     (info-xref-visited ((t (:underline t :foreground "#a8799c"))))
     (isearch ((t (:background "#483b39"))))
     (isearch-fail ((t (:background "#da5659"))))
     (lazy-highlight ((t (:foreground "#f7977a" :background "#1c1c1c"))))
     (link ((t (:foreground "#a8799c"))))
     (linum ((t (:italic t :foreground "#696969"))))
     (magit-branch ((t (:foreground "#c3be98"))))
     (magit-diff-add ((t (:foreground "#7ca563"))))
     (magit-diff-del ((t (:foreground "#d77261"))))
     (magit-item-highlight ((t (:background "#211612"))))
     (magit-section-title ((t (:foreground "#a8799c"))))
     (minibuffer-prompt ((t (:foreground "#c3be98"))))
     (mode-line ((t (:foreground "black" :background "#e5e894"))))
     (mode-line-highlight ((t (:foreground "#6d4c2f"))))
     (mode-line-inactive ((t (:foreground "black" :background "#999d63"))))
     (mumamo-background-chunk-submode1 ((t (:background "#1a0f0b"))))
     (py-builtins-face ((t (:foreground "#a8799c"))))
     (py-pseudo-keyword-face ((t (:foreground "#8a9a95"))))
     (py-XXX-tag-face ((t (:foreground "#cf6a4c"))))
     (region ((t (:background "#483b39"))))
     (show-paren-match-face ((t (:background "#483b39"))))
     (show-paren-mismatch-face ((t (:background "#7989a6"))))
     (w3m-anchor ((t (:foreground "#7989a6"))))
     (w3m-arrived-anchor ((t (:foreground "#d77261"))))
     (w3m-image ((t (:foreground "#679d47"))))
     (whitespace-trailing ((t (:background "#cf6a4c"))))
     (yas/field-highlight-face ((t (:background "#1c1c1c")))))))
