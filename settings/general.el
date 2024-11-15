(general-define-key :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "d" '(projectile-find-dir :which-key "Find directory")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(find-file :which-key "Find file")
 "o" '(consult-bookmark :which-key "Bookmarks")
 "v" '(simpleclip-paste :which-key "Paste")
 "y" '(consult-yank-pop :which-key "Yank Pop")
 "D" '(dired-jump :which-key "Dired")
 "F" '(projectile-find-file :which-key "Find file [project]")
 "R" '(consult-recent-file :which-key "Recent files")
 "SPC" '(consult-buffer :which-key "Switch buffer"))

(general-define-key :keymaps 'visual :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines"))

(general-define-key :prefix "SPC"
 "b" '(:ignore t :which-key "Buffer")
 "b d" '(delete-current-buffer-file :which-key "Delete file")
 "b e" '(eval-buffer :which-key "Eval buffer")
 "b h" '(bury-buffer :which-key "Hide buffer")
 "b i" '(highlight-indentation-mode :which-key "Highlight indentation")
 "b k" '(kill-this-buffer :which-key "Kill buffer")
 "b l" '(display-line-numbers-mode :which-key "Toggle line numbers")
 "b m" '(bm-toggle :which-key "Toggle visual bookmark")
 "b n" '(bm-next :which-key "Next bookmark")
 "b p" '(bm-previous :which-key "Previous bookmark")
 "b r" '(rename-current-buffer-file :which-key "Rename file")
 "b s" '(scratch :which-key "Create scratch buffer")
 "b w" '(whitespace-cleanup :which-key "Cleanup whitespace"))

(general-define-key :prefix "SPC"
  "E" '(:ignore t :which-key "Emacs")
  "E l" '(paradox-list-packages :which-key "List packages")
  "E q" '(save-buffers-kill-emacs :which-key "Quit Emacs")
  "E r" '(restart-emacs :which-key "Restart Emacs")
  "E u" '(paradox-upgrade-packages :which-key "Upgrade packages"))

(general-define-key :prefix "SPC"
 "h" '(:ignore t :which-key "Help")
 "h a" '(describe-face :which-key "Describe face")
 "h b" '(describe-bindings :which-key "Describe bindings")
 "h f" '(describe-function :which-key "Describe function")
 "h k" '(describe-key :which-key "Describe key")
 "h m" '(describe-mode :which-key "Describe mode")
 "h p" '(describe-package :which-key "Describe package")
 "h v" '(describe-variable :which-key "Describe variable"))

(general-define-key :prefix "SPC"
 "s" '(:ignore t :which-key "Search")
 "s a" '(consult-ripgrep :which-key "Search project")
 "s e" '(evil-iedit-state/iedit-mode :which-key "Iedit")
 "s r" '(projectile-replace :which-key "Projectile replace")
 "s s" '(consult-line :which-key "Search for matching line")
 "s v" '(avy-goto-word-1 :which-key "Avy"))

(general-define-key :keymaps 'evil-window-map
  "u" 'winner-undo
  "C-r" 'winner-redo

  "C-h" 'evil-window-left
  "C-j" 'evil-window-down
  "C-l" 'evil-window-right
  "C-k" 'evil-window-up

  "M-h" 'buf-move-left
  "M-j" 'buf-move-down
  "M-l" 'buf-move-right
  "M-k" 'buf-move-up)
