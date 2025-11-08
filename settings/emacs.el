(use-package emacs
  :ensure nil

  :init
  ;; Add prompt indicator to `completing-read-multiple'.
  ;; Displays [CRM<separator>], e.g., [CRM,] if the separator is a comma.
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
                  (replace-regexp-in-string
                   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" "" crm-separator)
                  (car args))
          (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt.
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  :custom
  (enable-recursive-minibuffers t)
  ; Hide irrelevant M-x commands
  (read-extended-command-predicate #'command-completion-default-include-p)
  (tab-always-indent 'complete)

  :config
  (electric-pair-mode 1)

  :general
  (:prefix "SPC b"
   "" '(:ignore t :which-key "Buffer")
   "d" '(delete-current-buffer-file :which-key "Delete file")
   "e" '(eval-buffer :which-key "Eval buffer")
   "h" '(bury-buffer :which-key "Hide buffer")
   "i" '(highlight-indentation-mode :which-key "Highlight indentation")
   "k" '((lambda () (interactive) (kill-this-buffer)) :which-key "Kill buffer")
   "m" '(bm-toggle :which-key "Toggle visual bookmark")
   "n" '(bm-next :which-key "Next bookmark")
   "p" '(bm-previous :which-key "Previous bookmark")
   "r" '(rename-current-buffer-file :which-key "Rename file")
   "s" '(scratch :which-key "Create scratch buffer")
   "w" '(whitespace-cleanup :which-key "Cleanup whitespace"))

  :general
  (:prefix "SPC E"
   "" '(:ignore t :which-key "Emacs")
   "l" '(package-list-packages :which-key "List packages")
   "q" '(save-buffers-kill-emacs :which-key "Quit Emacs")
   "r" '(restart-emacs :which-key "Restart Emacs")
   "t" '(consult-theme :which-key "Switch Theme")
   "u" '(package-upgrade-all :which-key "Upgrade all packages"))

  :general
  (:prefix "SPC h"
   "" '(:ignore t :which-key "Help")
   "a" '(describe-face :which-key "Describe face")
   "b" '(describe-bindings :which-key "Describe bindings")
   "f" '(describe-function :which-key "Describe function")
   "k" '(describe-key :which-key "Describe key")
   "m" '(describe-mode :which-key "Describe mode")
   "p" '(describe-package :which-key "Describe package")
   "v" '(describe-variable :which-key "Describe variable"))

  :general
  (:prefix "SPC t"
   "" '(:ignore t :which-key "Toggles")
   "l" '(display-line-numbers-mode :which-key "Toggle line numbers")))
