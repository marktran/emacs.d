(require-package 'evil)
(require-package 'evil-leader)
(require-package 'evil-numbers)
(require-package 'surround)

(setq evil-ex-search-vim-style-regexp t
      evil-leader/in-all-states t
      evil-leader/leader "SPC"
      evil-mode-line-format nil
      evil-search-module 'evil-search
      evil-want-C-u-scroll t)
(setq-default evil-shift-width 2)

;; https://github.com/cofi/evil-leader/issues/10
(evil-mode nil)
(global-evil-leader-mode t)
(evil-mode t)
(global-surround-mode t)

(loop for (mode . state) in '((inferior-emacs-lisp-mode . emacs)
                              (comint-mode              . emacs)
                              (eshell-mode              . emacs)
                              (sql-interactive-mode     . emacs))
      do (evil-set-initial-state mode state))

;; key bindings
(fill-keymap evil-normal-state-map
             "Y" (kbd "y$")
             "C-c +" 'evil-numbers/inc-at-pt
             "C-c -" 'evil-numbers/dec-at-pt)

(fill-keymap evil-window-map
             "u"   'winner-undo
             "C-r" 'winner-redo
             "M-h" 'buf-move-left
             "M-j" 'buf-move-down
             "M-k" 'buf-move-up
             "M-l" 'buf-move-right)

;; evil leader
(evil-leader/set-key
  "a" 'ag-project
  "A" 'ack
  "b" 'ido-switch-buffer
  "B" 'ido-switch-buffer-other-window
  "c" 'mc/mark-next-like-this
  "C" 'mc/edit-lines
  "d" 'dired-jump
  "D" 'toggle-current-window-dedication
  "e" 'er/expand-region
  "E" 'eshell
  "f" 'ido-find-file
  "F" 'fiplr-find-file
  "g" 'magit-status
  "k" 'kill-this-buffer
  "K" 'kill-buffer-and-window
  "l" 'linum-mode
  "m" 'bookmark-ido-find-file
  "o" 'browse-url-of-file
  "p" 'project-explorer-open
  "Q" 'save-buffers-kill-emacs
  "r" 'rspec-rerun
  "R" 'recentf-ido-find-file
  "S" 'scratch
  "t" 'ido-goto-symbol
  "SPC" 'whitespace-cleanup)

(evil-leader/set-key-for-mode 'ruby-mode "j" 'rspec-toggle-spec-and-target)
(evil-leader/set-key-for-mode 'ruby-mode "s" 'rspec-verify-single)
(evil-leader/set-key-for-mode 'ruby-mode "v" 'rspec-verify)

;; compilation mode
(add-hook 'compilation-mode-hook '(lambda ()
                                    (local-unset-key "h")
                                    (local-unset-key "0")
                                    (local-unset-key (kbd "SPC"))))

;; eshell mode
(defun eshell-evil-keys ()
  (define-key eshell-mode-map (kbd "C-w =") 'balance-windows)
  (define-key eshell-mode-map (kbd "C-w h") 'windmove-left)
  (define-key eshell-mode-map (kbd "C-w C-h") 'windmove-left)
  (define-key eshell-mode-map (kbd "C-w l") 'windmove-right)
  (define-key eshell-mode-map (kbd "C-w C-l") 'windmove-right)
  (define-key eshell-mode-map (kbd "C-w j") 'windmove-down)
  (define-key eshell-mode-map (kbd "C-w C-j") 'windmove-down)
  (define-key eshell-mode-map (kbd "C-w C-k") 'windmove-up)
  (define-key eshell-mode-map (kbd "C-w k") 'windmove-up)
  (define-key eshell-mode-map (kbd "C-w c") 'delete-window)
  (define-key eshell-mode-map (kbd "C-d") 'bury-buffer))

(add-hook 'eshell-mode-hook 'eshell-evil-keys)

;; emmet mode
(defadvice emmet-expand-line (after evil-normal-state activate)
  "Enable Normal state after expansion"
  (evil-normal-state))

;; org mode
(evil-declare-key 'normal org-mode-map
  "za"        'org-cycle
  "zA"        'org-shifttab
  "zc"        'hide-subtree
  "zm"        'hide-body
  "zo"        'show-subtree
  "zr"        'show-all
  (kbd "RET") 'org-open-at-point
  (kbd "C-u") 'universal-argument
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
