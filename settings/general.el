(general-define-key :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "d" '(projectile-find-dir :which-key "Find directory")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(counsel-find-file :which-key "Find file")
 "o" '(counsel-bookmark :which-key "Bookmarks")
 "v" '(simpleclip-paste :which-key "Paste")
 "y" '(counsel-yank-pop :which-key "Yank Pop")
 "D" '(dired-jump :which-key "Dired")
 "F" '(projectile-find-file :which-key "Find file [project]")
 "Q" '(save-buffers-kill-emacs :which-key "Quit Emacs")
 "R" '(counsel-recentf :which-key "Recent files")
 "SPC" '(ivy-switch-buffer :which-key "Switch buffer"))

(general-define-key :keymaps 'visual :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "c" '(simpleclip-copy :which-key "Copy region")
 "v" '(simpleclip-paste :which-key "Paste")
 "x" '(simpleclip-cut :which-key "Cut region"))

(general-define-key :prefix "SPC"
 "b" '(:ignore t :which-key "Buffer")
 "b d" '(delete-current-buffer-file :which-key "Delete file")
 "b e" '(eval-buffer :which-key "Eval buffer")
 "b h" '(bury-buffer :which-key "Hide buffer")
 "b k" '(kill-this-buffer :which-key "Kill buffer")
 "b m" '(bm-toggle :which-key "Toggle visual bookmark")
 "b n" '(bm-next :which-key "Next bookmark")
 "b p" '(bm-previous :which-key "Previous bookmark")
 "b r" '(rename-current-buffer-file :which-key "Rename file")
 "b s" '(scratch :which-key "Create scratch buffer")
 "b w" '(whitespace-cleanup :which-key "Cleanup whitespace"))

(general-define-key :prefix "SPC"
 "h" '(:ignore t :which-key "Help")
 "h a" '(describe-face :which-key "Describe face")
 "h b" '(describe-bindings :which-key "Describe bindings")
 "h d" '(counsel-descbinds :which-key "Search bindings")
 "h f" '(counsel-describe-function :which-key "Describe function")
 "h k" '(describe-key :which-key "Describe key")
 "h m" '(describe-mode :which-key "Describe mode")
 "h p" '(describe-package :which-key "Describe package")
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
 "t l" '(nlinum-mode :which-key "Toggle line numbers"))
