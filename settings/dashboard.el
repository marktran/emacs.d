(use-package dashboard
  :custom
  (dashboard-startup-banner 'logo)
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
  (dashboard-setup-startup-hook))
