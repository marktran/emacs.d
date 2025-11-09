(general-define-key :prefix "SPC"
 "." '(dired-jump :which-key "Dired")
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
 "c" '(org-capture :which-key "Capture")
 "e" '(er/expand-region :which-key "Expand region")
 "f" '(find-file :which-key "Find file")
 "p" '(disproject-dispatch :which-key "Project")
 "y" '(consult-yank-pop :which-key "Yank Pop")
 "R" '(consult-recent-file :which-key "Recent files")
 "RET" '(consult-bookmark :which-key "Bookmarks")
 "SPC" '(consult-buffer :which-key "Switch buffer"))

(general-define-key :keymaps 'visual :prefix "SPC"
 ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines"))

(general-define-key :prefix "SPC n"
 "" '(:ignore t :which-key "Notes")
 "a" '((lambda () (interactive) (org-agenda nil "n")) :which-key "Agenda")
 "c" '(toggle-calendar :which-key "Toggle calendar")
 "d" '(denote-journal-new-or-existing-entry :which-key "Jump to daily entry")
 "f" '(consult-notes :which-key "Find notes")
 "n" '(denote-create-note :which-key "Create note")
 "s" '(consult-denote-grep :which-key "Search notes"))

(general-define-key :prefix "SPC s"
 "" '(:ignore t :which-key "Search")
 "a" '(consult-ripgrep :which-key "Search project")
 "e" '(evil-iedit-state/iedit-mode :which-key "Iedit")
 "s" '(consult-line :which-key "Search for matching line")
 "v" '(avy-goto-word-1 :which-key "Avy"))
