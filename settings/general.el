(general-define-key :prefix "SPC"
 "." '(dired-jump :which-key "Dired")
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(find-file :which-key "Find file")
 "o" '(consult-bookmark :which-key "Bookmarks")
 "y" '(consult-yank-pop :which-key "Yank Pop")
 "R" '(consult-recent-file :which-key "Recent files")
 "SPC" '(consult-buffer :which-key "Switch buffer"))

(general-define-key :keymaps 'visual :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines"))

(general-define-key :prefix "SPC s"
 "" '(:ignore t :which-key "Search")
 "a" '(consult-ripgrep :which-key "Search project")
 "e" '(evil-iedit-state/iedit-mode :which-key "Iedit")
 "s" '(consult-line :which-key "Search for matching line")
 "v" '(avy-goto-word-1 :which-key "Avy"))
