(evil-mode t)

(setq evil-ex-search-vim-style-regexp t
      evil-leader/in-all-states t
      evil-leader/leader ","
      evil-mode-line-format nil
      evil-move-cursor-back t
      evil-search-module 'evil-search)
(setq-default evil-shift-width 2)

(define-key evil-motion-state-map evil-leader/leader evil-leader/map)

(loop for (mode . state) in '((inferior-emacs-lisp-mode      . emacs)
                              (comint-mode                   . emacs)
                              (eshell-mode                   . emacs)
                              (magit-branch-manager-mode     . emacs)
                              (magit-log-edit-mode           . emacs)
                              (sql-interactive-mode          . emacs))
      do (evil-set-initial-state mode state))

;; key bindings
(fill-keymap evil-normal-state-map
             "SPC"   'ace-jump-char-mode
             "C-c +" 'evil-numbers/inc-at-pt
             "C-c -" 'evil-numbers/dec-at-pt)

(fill-keymap evil-window-map
             "SPC" 'swap-window
             "u"   'winner-undo
             "C-r" 'winner-redo
             "M-h" 'swap-with-left
             "M-j" 'swap-with-down
             "M-k" 'swap-with-up
             "M-l" 'swap-with-right)

;; evil leader
(evil-leader/set-key
  "a" 'ack
  "b" 'ido-switch-buffer
  "B" 'ido-switch-buffer-other-window
  "c" 'comment-dwim-line
  "d" (cmd (dired-single-magic-buffer default-directory))
  "D" 'toggle-current-window-dedication
  "e" 'er/expand-region
  "f" 'ido-find-file
  "F" 'ido-find-file-other-window
  "g" 'magit-status
  "k" 'kill-this-buffer
  "K" 'kill-buffer-and-window
  "m" 'bookmark-ido-find-file
  "o" 'browse-url-of-file
  "r" 'recentf-ido-find-file
  "s" 'rspec-verify-single
  "t" 'ido-goto-symbol
  "v" 'rspec-verify)

;; compilation mode
(evil-declare-key 'motion compilation-mode-map
                  "h" 'evil-backward-char
                  "0" 'evil-digit-argument-or-evil-beginning-of-line)

;; dired mode
(evil-declare-key 'normal dired-mode-map
                  "^" (cmd (dired-single-buffer ".."))
                  (kbd "RET") 'dired-single-buffer)

;; org mode
(evil-declare-key 'normal org-mode-map
                  "za"        'org-cycle
                  "zA"        'org-shifttab
                  "zc"        'hide-subtree
                  "zC"        'org-hide-block-all
                  "zm"        'hide-body
                  "zo"        'show-subtree
                  "zO"        'show-all
                  "zr"        'show-all
                  (kbd "RET") 'org-open-at-point
                  (kbd "M-j") 'org-shiftleft
                  (kbd "M-k") 'org-shiftright
                  (kbd "M-H") 'org-metaleft
                  (kbd "M-J") 'org-metadown
                  (kbd "M-K") 'org-metaup
                  (kbd "M-L") 'org-metaright)

(evil-declare-key 'insert org-mode-map
                  (kbd "M-j") 'org-shiftleft
                  (kbd "M-k") 'org-shiftright
                  (kbd "M-H") 'org-metaleft
                  (kbd "M-J") 'org-metadown
                  (kbd "M-K") 'org-metaup
                  (kbd "M-L") 'org-metaright)
