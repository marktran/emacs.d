(setq evil-leader/in-all-states t
      evil-leader/leader ","
      evil-mode-line-format nil
      evil-move-cursor-back t
      evil-want-C-u-scroll t)
(setq-default evil-shift-width 2)

(add-hook 'python-mode-hook
  (function (lambda ()
          (setq evil-shift-width python-indent))))

(require 'evil-leader)

(evil-mode 1)
(define-key evil-motion-state-map evil-leader/leader evil-leader/map)
(when evil-want-C-u-scroll
    (define-key evil-motion-state-map (kbd "C-u") 'evil-scroll-up))

(evil-leader/set-key
  "a" 'bookmark-ido-find-file
  "b" 'ido-switch-buffer
  "d" 'dired-jump
  "e" 'eshell
  "f" 'ido-find-file
  "g" 'magit-status
  "k" 'kill-this-buffer
  "o" 'browse-url-of-file
  "r" 'recentf-ido-find-file
  "s" 'rspec-verify-single
  "t" 'ido-goto-symbol)

(loop for (mode . state) in '((inferior-emacs-lisp-mode      . emacs)
                              (comint-mode                   . emacs)
                              (eshell-mode                   . emacs)
                              (magit-show-branches-mode      . emacs)
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

(fill-keymap evil-window-map
             "M-h"       'swap-with-left
             "M-j"       'swap-with-down
             "M-k"       'swap-with-up
             "M-l"       'swap-with-right
             "S-<left>"  'swap-with-left
             "S-<down>"  'swap-with-down
             "S-<up>"    'swap-with-up
             "S-<right>" 'swap-with-right
             "SPC"       'swap-window

             "u" 'winner-undo
             "C-r" 'winner-redo)

(provide 'mqt-evil)
