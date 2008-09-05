;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/web.el : Mark Tran <mark@nirv.net>

(add-to-list 'load-path "/usr/share/emacs/site-lisp/w3m")
(autoload 'w3m "w3m-load" "Interface for w3m on emacs." t)

(eval-after-load 'w3m
  '(progn
     (setq w3m-home-page "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-4.html#%_toc_start")
     (setq w3m-show-graphic-icons-in-mode-line nil)
     (setq w3m-use-header-line nil)
     (setq w3m-use-tab nil)
     (setq w3m-use-toolbar nil)))

(setq w3m-content-type-alist
      '(("text/html" "\\.s?html?$" browse-url-generic)
        ("text/plain" "\\.\\(txt\\|tex\\|el\\)" nil)
        ("application/postscript" "\\.\\(ps\\|eps\\)$" ("gv" file))
        ("application/pdf" "\\.pdf$" ("kpdf" file))
        ("image/jpeg" "\\.jpe?g$" ("/usr/bin/display" file))
        ("image/png" "\\.png$" ("/usr/bin/display" file))
        ("image/gif" "\\.gif$" ("/usr/bin/display" file))
        ("image/tiff" "\\.tif?f$" ("/usr/bin/display" file))
        ("image/x-xwd" "\\.xwd$" ("/usr/bin/display" file))
        ("image/x-xbm" "\\.xbm$" ("/usr/bin/display" file))
        ("image/x-xpm" "\\.xpm$" ("/usr/bin/display" file))
        ("image/x-bmp" "\\.bmp$" ("/usr/bin/display" file))
        ("video/mpeg" "\\.mpe?g$" ("mplayer" file))
        ("video/quicktime" "\\.mov$" ("mplayer" file))))

(setq browse-url-browser-function 'browse-url-generic)

(provide 'web)


