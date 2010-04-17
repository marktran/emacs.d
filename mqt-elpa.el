;;; -*- Mode: Emacs-Lisp; -*-

;;; .emacs.d/mqt-elpa.el : Mark Tran <mark@nirv.net>

(defvar elpa-packages (list 'clojure-mode
                            'fringe-helper
                            'full-ack
                            'gist
                            'haml-mode
                            'htmlize
                            'inf-ruby
                            'js2-mode
                            'json
                            'kill-ring-search
                            'pastie
                            'rinari
                            'ruby-compilation
                            'ruby-mode
                            'smex
                            'yaml-mode)
  "Libraries that should be installed by default.")

(defun mqt-elpa-install ()
  "Install all starter-kit packages that aren't installed."
  (interactive)
  (dolist (package elpa-packages)
    (unless (or (member package package-activated-list)
                (functionp package))
      (message "Installing %s" (symbol-name package))
      (package-install package))))

(defun mqt-online? ()
  "See if we're online."
  (if (and (functionp 'network-interface-list)
           (network-interface-list))
      (some (lambda (iface) (unless (equal "lo" (car iface))
                         (member 'up (first (last (network-interface-info
                                                   (car iface)))))))
            (network-interface-list))
    t))

(when (mqt-online?)
  (unless package-archive-contents (package-refresh-contents))
  (mqt-elpa-install))

(provide 'mqt-elpa)
