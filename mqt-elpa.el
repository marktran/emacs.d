;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-elpa.el : Mark Tran <mark@nirv.net>

(defvar elpa-packages (list 'gist
                            'inf-ruby
                            'kill-ring-search
                            'lua-mode
                            'magit
                            'paredit
                            'ruby-mode
                            'xml-rpc
                            'yasnippet-bundle)
  "Libraries that should be installed by default.")
 
(defun elpa-install ()
  "Install all starter-kit packages that aren't installed."
  (interactive)
  (dolist (package elpa-packages)
    (unless (or (member package package-activated-list)
                (functionp package))
      (message "Installing %s" (symbol-name package))
      (package-install package))))
 
(defun online? ()
  "See if we're online."
  (if (and (functionp 'network-interface-list)
           (network-interface-list))
      (some (lambda (iface) (unless (equal "lo" (car iface))
                         (member 'up (first (last (network-interface-info
                                                   (car iface)))))))
            (network-interface-list))
    t))
 
(when (online?)
  (unless package-archive-contents (package-refresh-contents))
  (elpa-install))

(provide 'mqt-elpa)
