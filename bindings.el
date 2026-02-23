(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)
(global-set-key [remap fill-paragraph] #'fill-or-unfill)

(use-package general
  :ensure t
  :custom
  (general-default-keymaps 'evil-normal-state-map)

  :config
  (general-define-key :prefix "SPC"
   "." '(dired-jump :which-key "Dired")
   ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines")
   "c" '(toggle-calendar :which-key "Toggle calendar")
   "e" '(er/expand-region :which-key "Expand region")
   "f" '(find-file :which-key "Find file")
   "p" '(disproject-dispatch :which-key "Project")
   "y" '(consult-yank-pop :which-key "Yank Pop")
   "R" '(consult-recent-file :which-key "Recent files")
   "RET" '(consult-bookmark :which-key "Bookmarks")
   "a" '(gptel :which-key "AI chat")
   "SPC" '(consult-buffer :which-key "Switch buffer"))

  (general-define-key :keymaps 'visual :prefix "SPC"
   ";" '(evilnc-comment-or-uncomment-lines :which-key "Comment/uncomment lines"))

  (general-define-key :prefix "SPC n"
   "" '(:ignore t :which-key "Notes")
   "a" '((lambda () (interactive) (org-agenda nil "n")) :which-key "Agenda")
   "d" '(denote-journal-new-or-existing-entry :which-key "Jump to daily entry")
   "f" '(consult-notes :which-key "Find notes")
   "n" '(denote-create-note :which-key "Create note")
   "s" '(consult-denote-grep :which-key "Search notes"))

  (general-define-key :prefix "SPC s"
   "" '(:ignore t :which-key "Search")
   "a" '(consult-ripgrep :which-key "Search project")
   "e" '(evil-iedit-state/iedit-mode :which-key "Iedit")
   "s" '(consult-line :which-key "Search for matching line")
   "v" '(avy-goto-word-1 :which-key "Avy")))

(use-package hydra
  :ensure t)

(use-package which-key
  :ensure t
  :diminish which-key-mode

  :custom
  (which-key-idle-delay 0.5)
  (which-key-show-prefix nil)
  (which-key-sort-order 'which-key-prefix-then-key-order)

  :config
  (which-key-mode 1))
