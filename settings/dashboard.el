(use-package dashboard
  :ensure t

  :custom
  (dashboard-banner-logo-title "Happy Hacking!")
  (dashboard-startup-banner "~/.emacs.d/assets/emacs-logo.svg")
  (dashboard-center-content t)
  (dashboard-items '((projects . 4)
                     (recents . 4)
                     (bookmarks . 4)))
  (dashboard-set-file-icons t)
  (dashboard-set-heading-icons t)
  (dashboard-footer-messages
        '("The man who moves a mountain begins by carrying away small stones."
          "The superior man is modest in his speech, but exceeds in his actions."
          "The strength of a nation derives from the integrity of the home."))

  :config
  ;; `dashboard-insert-shortcut' expands to (eval-after-load 'dashboard
  ;; (dashboard--define-shorcut-key-binding ...)): the form is evaluated
  ;; into that function's return value — the last-bound section-cycling
  ;; command — which `eval-after-load' then funcalls on every dashboard
  ;; render, moving point around the half-built buffer and messaging
  ;; "Only one tabable widget". Returning nil instead leaves
  ;; `eval-after-load' nothing to run; the key bindings still happen as
  ;; side effects. Drop this workaround once
  ;; https://github.com/emacs-dashboard/dashboard/issues/609 is fixed.
  (advice-add 'dashboard--define-shorcut-key-binding :filter-return #'ignore)

  (dashboard-setup-startup-hook))
