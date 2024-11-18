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

  :general
  (:prefix "SPC E"
   "" '(:ignore t :which-key "Emacs")
   "l" '(package-list-packages :which-key "List packages")
   "q" '(save-buffers-kill-emacs :which-key "Quit Emacs")
   "r" '(restart-emacs :which-key "Restart Emacs")
   "t" '(consult-theme :which-key "Switch Theme")
   "u" '(package-upgrade-all :which-key "Upgrade all packages")))
