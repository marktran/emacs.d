;;; .emacs.d/mqt-misc.el : Mark Tran <mark.tran@gmail.com>

(if (not (file-exists-p "~/.emacs.d/backups"))
    (make-directory "~/.emacs.d/backups" t))

;; load
(cua-mode 1)
(desktop-save-mode 1)
(global-auto-revert-mode 1)
(ido-mode 1)
(recentf-mode 1)

;; settings
(setq auto-save-default nil
      backup-by-copying t
      backup-directory-alist '(("." . "~/.emacs.d/backups"))
      comment-auto-fill-only-comments t
      compilation-message-face nil
      confirm-nonexistent-file-or-buffer nil
      css-indent-offset 2
      cua-enable-cua-keys nil
      desktop-dirname "~/.emacs.d/"
      disabled-command-function nil
      display-time-24hr-format t
      display-time-default-load-average nil
      ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain
      eshell-aliases-file "~/.emacs.d/eshell/alias"
      eshell-banner-message ""
      eshell-last-dir-ring-size 10
      eshell-list-files-after-cd t
      gnus-home-directory "~/.gnus.d/"
      gnus-init-file "~/.emacs.d/.gnus.el"
      history-length 250
      ido-create-new-buffer 'always
      ido-enable-flex-matching t
      ido-everywhere t
      ido-ignore-buffers `("\\` "
                           "^\\*Compile-Log\\*"
                           "^\\*Completions\\*"
                           "^\\*growl\\*"
                           "^\\*Help\\*"
                           "^\\*Ido"
                           "^\\*IPython"
                           "^\\*Messages\\*"
                           "^\\*magit"
                           "^\\*Pymacs\\*"
                           "^\\*Python Output\\*"
                           "^\\*RE-Builder\\*"
                           "^\\*Shell Command Output\\*"
                           "^\\*XML Validation Header\\*"
                           "^Dired:"
                           ,(lambda (name)
                              (if (derived-mode-p 'erc-mode)
                                  (with-current-buffer name
                                    (not (derived-mode-p 'erc-mode)))
                                (with-current-buffer name
                                  (derived-mode-p 'erc-mode)))))
      ido-use-filename-at-point nil
      initial-scratch-message nil
      isearch-lazy-highlight nil
      ispell-program-name "aspell"
      js-indent-level 2
      kill-buffer-query-functions (remq 'process-kill-buffer-query-function
                                        kill-buffer-query-functions)
      ns-pop-up-frames nil
      org-completion-use-ido t
      org-log-done 'time
      recentf-max-menu-items 25
      require-final-newline nil
      scroll-conservatively 100000
      scroll-margin 0
      scroll-preserve-screen-position 1
      sql-mysql-program "postgres"
      tramp-default-method "ssh"
      tramp-mode nil
      uniquify-buffer-name-style 'forward
      uniquify-ignore-buffers-re "^\\*"
      vc-handled-backends '(git)
      whitespace-style '(lines-tail
                         space-after-tab
                         space-before-tab
                         trailing)
      windmove-wrap-around t)

(setq-default c-basic-offset 4
              fill-column 72
              indent-tabs-mode nil
              tab-width 4
              truncate-lines t)

(c-set-offset 'case-label '+)
(fset 'yes-or-no-p 'y-or-n-p)

(dolist (mode '(("Cakefile" . coffee-mode)
                ("Capfile" . ruby-mode)
                ("Gemfile" . ruby-mode)
                ("Guardfile" . ruby-mode)
                ("Rakefile" . ruby-mode)
                ("\\.coffee$" . coffee-mode)
                ("\\.css$" . css-mode)
                ("\\.csv$" . csv-mode)
                ("\\.eco$" . rhtml-mode)
                ("\\.gemspec$" . ruby-mode)
                ("\\.jbuilder$" . ruby-mode)
                ("\\.js$" . js-mode)
                ("\\.less$" . css-mode)
                ("\\.md$" . markdown-mode)
                ("\\.pjs$" . js-mode)
                ("\\.html$" . html-mode)
                ("\\.xml$" . nxml-mode)
                ("\\.ya?ml$" . yaml-mode)
                ("\\.zsh$" . shell-script-mode)))
  (add-to-list 'auto-mode-alist mode))

;; eshell visual commands
(add-hook 'eshell-mode-hook
          (lambda ()
            (dolist (command '("htop"
                               "ssh"))
              (add-to-list 'eshell-visual-commands command))

            (local-set-key (kbd "C-w C-k") 'windmove-up)
            (local-set-key (kbd "C-w C-l") 'windmove-right)
            (local-set-key (kbd "C-w C-j") 'windmove-down)
            (local-set-key (kbd "C-w C-h") 'windmove-left)

            (local-set-key (kbd "C-w k") 'windmove-up)
            (local-set-key (kbd "C-w l") 'windmove-right)
            (local-set-key (kbd "C-w j") 'windmove-down)
            (local-set-key (kbd "C-w h") 'windmove-left)))

;; names of buffers that should appear in the "same" window
(dolist (name '("*SQL*"))
  (add-to-list 'same-window-buffer-names name))

;; hooks
(add-hook 'after-save-hook 'executable-make-buffer-file-executable-if-script-p)
(add-hook 'comint-mode-hook 'turn-on-visual-line-mode)
(add-hook 'dired-after-readin-hook
          (lambda ()
            (rename-buffer (concat "Dired:" (directory-file-name dired-directory)))))
(add-hook 'ediff-cleanup-hook (lambda () (ediff-janitor nil nil)))
(add-hook 'ido-setup-hook
          (lambda ()
            (define-key ido-completion-map [tab] 'ido-complete)))

(provide 'mqt-misc)
