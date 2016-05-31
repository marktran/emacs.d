(use-package evil
  :init
  (setq evil-ex-search-vim-style-regexp t
        evil-mode-line-format nil
        evil-search-module 'evil-search
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t)
  (setq-default evil-shift-width 2))

(use-package evil-leader
  :config
  (setq evil-leader/in-all-states t
        evil-leader/leader "SPC"))

(use-package evil-iedit-state :commands evil-iedit-state/iedit-mode)
(use-package evil-matchit)
(use-package evil-nerd-commenter :commands evilnc-comment-or-uncomment-lines)
(use-package evil-numbers :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-t))
(use-package evil-surround)

;; https://github.com/cofi/evil-leader/issues/10
(evil-mode nil)
(global-evil-leader-mode t)
(evil-mode t)
(global-evil-surround-mode t)
(global-evil-matchit-mode t)

(loop for (mode . state) in '((inferior-emacs-lisp-mode . emacs)
                              (comint-mode              . emacs)
                              (eshell-mode              . emacs)
                              (occur-mode               . emacs)
                              (paradox-menu-mode        . emacs)
                              (sql-interactive-mode     . emacs)
                              (text-mode                . emacs))
      do (evil-set-initial-state mode state))

;; key bindings
(fill-keymap evil-normal-state-map
             "C-c +" 'evil-numbers/inc-at-pt
             "C-c -" 'evil-numbers/dec-at-pt)

(fill-keymap evil-window-map
             "u"   'winner-undo
             "C-h" 'evil-window-left
             "C-l" 'evil-window-right
             "C-j" 'evil-window-down
             "C-k" 'evil-window-up
             "C-r" 'winner-redo
             "M-h" 'buf-move-left
             "M-j" 'buf-move-down
             "M-k" 'buf-move-up
             "M-l" 'buf-move-right)

;; evil leader
(evil-leader/set-key
  "E" 'eshell
  "F" 'projectile-find-file
  "O" 'browse-url-of-file
  "Q" 'save-buffers-kill-emacs
  "R" 'ivy-recentf
  "d" 'projectile-find-dir
  "D" 'dired-jump
  "e" 'er/expand-region
  "f" 'counsel-find-file
  "o" 'counsel-bookmark
  "c" 'simpleclip-copy
  "v" 'simpleclip-paste
  "x" 'simpleclip-cut
  "SPC" 'ivy-switch-buffer

  "bd" 'delete-current-buffer-file
  "be" 'eval-buffer
  "bh" 'bury-buffer
  "bk" 'kill-this-buffer
  "br" 'rename-current-buffer-file
  "bs" 'scratch
  "bw" 'whitespace-cleanup

  "gs" 'magit-status
  "gb" 'magit-blame
  "gl" 'magit-log-current
  "gL" 'magit-log-buffer-file

  "hb" 'describe-bindings
  "hd" 'counsel-descbinds
  "hf" 'counsel-describe-function
  "hk" 'describe-key
  "hm" 'describe-mode
  "hv" 'counsel-describe-variable

  "pb" 'projectile-switch-to-buffer
  "pD" 'projectile-dired
  "pd" 'projectile-find-dir
  "pe" 'project-explorer-open
  "pi" 'projectile-invalidate-cache
  "pj" 'projectile-find-tag
  "pk" 'projectile-kill-buffers
  "pl" 'paradox-list-packages
  "pp" 'projectile-switch-project
  "pR" 'projectile-regenerate-tags
  "pr" 'projectile-recentf
  "ps" 'projectile-run-eshell

  "rf" 'rspec-verify
  "rr" 'rspec-rerun
  "rs" 'rspec-verify-single

  "sa" 'counsel-ag-project-symbol
  "se" 'evil-iedit-state/iedit-mode
  "ss" 'swiper
  "sv" 'avy-goto-word-1

  "tg" 'toggle-golden-ratio-mode
  "tl" 'linum-mode

  "wpm" 'popwin:messages
  "wpc" 'popwin:close-popup-window
  "wpl" 'popwin:popup-last-buffer)

(evil-leader/set-key-for-mode 'ruby-mode "j" 'rspec-toggle-spec-and-target)

(define-key evil-insert-state-map [remap newline] 'evil-ret-and-indent)

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
  (define-key eshell-mode-map (kbd "C-w C-o") 'delete-other-windows)
  (define-key eshell-mode-map (kbd "C-w k") 'windmove-up)
  (define-key eshell-mode-map (kbd "C-w c") 'delete-window)
  (define-key eshell-mode-map (kbd "C-w u") 'winner-undo)
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
