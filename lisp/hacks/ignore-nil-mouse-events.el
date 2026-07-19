;; On PGTK/Wayland a stray click sometimes reaches Emacs with a position
;; that resolves to no live window — typically the wake/unlock click
;; after suspend/resume, delivered before the frame's surface state has
;; settled.  read-key-sequence prefixes such events with the symbol nil
;; and echoes "<nil> <mouse-1> is undefined".  Harmless but noisy;
;; swallow it.  (Unbound *down* events are already discarded silently,
;; so only the click needs a binding.)
(global-set-key [nil mouse-1] #'ignore)

(provide 'ignore-nil-mouse-events)
