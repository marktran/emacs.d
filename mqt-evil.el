(setq evil-leader/in-all-states t
      evil-mode-line-format nil
      evil-want-C-u-scroll t)

(add-hook 'python-mode-hook
  (function (lambda ()
          (setq evil-shift-width python-indent))))

(add-hook 'ruby-mode-hook
  (function (lambda ()
          (setq evil-shift-width ruby-indent-level))))

(require 'evil)
(require 'evil-leader)
(evil-mode 1)

(add-to-list 'evil-emacs-state-modes 'magit-log-edit-mode)

(evil-leader/set-leader ",")
(evil-leader/set-key
  "b" 'ido-switch-buffer
  "f" 'ido-find-file
  "g" 'magit-status
  "k" 'kill-this-buffer
  "r" 'recentf-ido-find-file
  "s" 'suspend-frame
  "t" 'ido-goto-symbol)

(when evil-want-C-u-scroll
    (define-key evil-motion-state-map (kbd "C-u") 'evil-scroll-up))

(evil-declare-key 'normal org-mode-map
  (kbd "RET") 'org-open-at-point
  "za"        'org-cycle
  "zA"        'org-shifttab
  "zm"        'hide-body
  "zr"        'show-all
  "zo"        'show-subtree
  "zO"        'show-all
  "zc"        'hide-subtree
  "zC"        'hide-all
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

(provide 'mqt-evil)