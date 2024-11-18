(general-define-key :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(find-file :which-key "Find file")
 "o" '(consult-bookmark :which-key "Bookmarks")
 "v" '(simpleclip-paste :which-key "Paste")
 "y" '(consult-yank-pop :which-key "Yank Pop")
 "D" '(dired-jump :which-key "Dired")
 "R" '(consult-recent-file :which-key "Recent files")
 "SPC" '(consult-buffer :which-key "Switch buffer"))

(general-define-key :keymaps 'visual :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines"))

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
