(use-package which-key
  :diminish which-key-mode

  :config
  (setq which-key-idle-delay 0.5
        which-key-show-prefix nil
        which-key-sort-order 'which-key-prefix-then-key-order)

  (which-key-mode 1))

(use-package general
  :config
  (setq general-default-keymaps 'evil-normal-state-map
        general-default-prefix "SPC"))

(general-define-key
 "c" '(simpleclip-copy :which-key "Copy region")
 "d" '(projectile-find-dir :which-key "Find directory")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(counsel-find-file :which-key "Find file")
 "o" '(counsel-bookmark :which-key "Bookmarks")
 "v" '(simpleclip-paste :which-key "Paste")
 "x" '(simpleclip-cut :which-key "Cut region")
 "D" '(dired-jump :which-key "Dired")
 "F" '(projectile-find-file :which-key "Find file [project]")
 "Q" '(save-buffers-kill-emacs :which-key "Quit Emacs")
 "R" '(ivy-recentf :which-key "Recent files")
 "SPC" '(ivy-switch-buffer :which-key "Switch buffer"))

(general-define-key :prefix "SPC"
 "b" '(:ignore t :which-key "Buffer")
 "b d" '(delete-current-buffer-file :which-key "Delete file")
 "b e" '(eval-buffer :which-key "Eval buffer")
 "b h" '(bury-buffer :which-key "Hide buffer")
 "b k" '(kill-this-buffer :which-key "Kill buffer")
 "b r" '(rename-current-buffer-file :which-key "Rename file")
 "b s" '(scratch :which-key "Create scratch buffer")
 "b w" '(whitespace-cleanup :which-key "Cleanup whitespace"))

(general-define-key :prefix "SPC"
 "h" '(:ignore t :which-key "Help")
 "h b" '(describe-bindings :which-key "Describe bindings")
 "h d" '(counsel-descbinds :which-key "Search bindings")
 "h f" '(counsel-describe-function :which-key "Describe function")
 "h k" '(describe-key :which-key "Describe key")
 "h m" '(describe-mode :which-key "Describe mode")
 "h v" '(counsel-describe-variable :which-key "Describe variable"))

(general-define-key :prefix "SPC"
 "s" '(:ignore t :which-key "Search")
 "s a" '(counsel-ag-project-symbol :which-key "Search project")
 "s e" '(evil-iedit-state/iedit-mode :which-key "Iedit")
 "s s" '(swiper :which-key "Swiper")
 "s v" '(avy-goto-word-1 :which-key "Avy"))

(general-define-key :prefix "SPC"
 "t" '(:ignore t :which-key "Toggle")
 "t g" '(toggle-golden-ratio-mode :which-key "Toggle Golden Ratio sizing")
 "t l" '(linum-mode :which-key "Toggle line numbers"))
