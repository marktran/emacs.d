(evil-mode t)
(require 'evil-leader)

(setq evil-leader/in-all-states t
      evil-leader/leader ","
      evil-mode-line-format nil
      evil-move-cursor-back t
      evil-want-C-u-scroll t)
(setq-default evil-shift-width 2)

(define-key evil-motion-state-map evil-leader/leader evil-leader/map)
(when evil-want-C-u-scroll
    (define-key evil-motion-state-map (kbd "C-u") 'evil-scroll-up))

(evil-leader/set-key
  "a" 'ack
  "b" 'ido-switch-buffer
  "B" 'ido-switch-buffer-other-window
  "c" 'comment-dwim-line
  "d" 'dired-jump
  "f" 'ido-find-file
  "F" 'ido-find-file-other-window
  "g" 'magit-status
  "k" 'kill-this-buffer
  "m" 'bookmark-ido-find-file
  "o" 'browse-url-of-file
  "r" 'recentf-ido-find-file
  "s" 'rspec-verify-single
  "t" 'ido-goto-symbol
  "v" 'rspec-verify)

(loop for (mode . state) in '((inferior-emacs-lisp-mode      . emacs)
                              (comint-mode                   . emacs)
                              (eshell-mode                   . emacs)
                              (magit-branch-manager-mode     . emacs)
                              (magit-log-edit-mode           . emacs)
                              (sql-interactive-mode          . emacs))
      do (evil-set-initial-state mode state))

(evil-declare-key 'normal org-mode-map
  (kbd "RET") 'org-open-at-point
  "za"        'org-cycle
  "zA"        'org-shifttab
  "zm"        'hide-body
  "zr"        'show-all
  "zo"        'show-subtree
  "zO"        'show-all
  "zc"        'hide-subtree
  "zC"        'org-hide-block-all
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

(eval-after-load 'compile
  '(progn
     (evil-define-key 'motion compilation-mode-map "h" 'evil-backward-char)
     (evil-define-key 'motion compilation-mode-map "0" 'evil-digit-argument-or-evil-beginning-of-line)))

(fill-keymap evil-normal-state-map
             "SPC" 'ace-jump-char-mode)

(fill-keymap evil-window-map
             "M-h" 'swap-with-left
             "M-j" 'swap-with-down
             "M-k" 'swap-with-up
             "M-l" 'swap-with-right
             "SPC" 'swap-window
             "u"   'winner-undo
             "C-r" 'winner-redo)
