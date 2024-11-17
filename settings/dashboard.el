(use-package dashboard
  :custom
  (dashboard-banner-logo-title "Happy Hacking!")
  (dashboard-startup-banner "~/.emacs.d/vendor/emacs-logo.svg")
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
  (dashboard-setup-startup-hook)

  (general-define-key
   :keymaps 'dashboard-mode-map
   :states 'normal
   "p" 'dashboard-jump-to-projects
   "r" 'dashboard-jump-to-recents
   "1" 'dashboard-section-1
   "2" 'dashboard-section-2
   "3" 'dashboard-section-3
   "4" 'dashboard-section-4
   "5" 'dashboard-section-5))
