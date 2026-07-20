;; Emacs 30 pointlessly async-native-compiles tramp-loaddefs.el.gz and
;; org-loaddefs.el.gz in every session that loads tramp or org, creating
;; the *Async-native-compile-log* buffer each time.  Verified with
;; emacs -Q on Arch's emacs 30.2; the underlying bugs are still present
;; in emacs master as of 2026-07.
;;
;; The chain:
;;
;; - Arch ships tramp-loaddefs.elc / org-loaddefs.elc.  Their sources
;;   are marked `no-native-compile: t' (but not `no-byte-compile'), so
;;   the AOT build produces the .elc but, deliberately, no .eln.
;; - Loading a .elc that has no .eln makes each defun/defalias in it
;;   queue a JIT native compilation of the source file
;;   (maybe_defer_native_compilation in src/comp.c).
;; - Two guards should cancel that for no-native-compile files; both
;;   fail:
;;   1. The C guard consults the `comp-no-native-file-h' hash, but the
;;      marker such a .elc registers about itself when loaded goes into
;;      a different hash, `comp--no-native-compile' (from loadup.el).
;;   2. `native--compile-async-skip-p' (comp-run.el) consults the right
;;      hash but derives the key with (file-name-with-extension file
;;      "elc"), which only replaces the last extension.  Arch gzips
;;      sources, so ".../tramp-loaddefs.el.gz" yields the key
;;      ".../tramp-loaddefs.el.elc" while ".../tramp-loaddefs.elc" was
;;      registered.  The lookup misses.  (Unzipped installs compute the
;;      right key, which is why this mostly bites gzipping distros.)
;; - The async worker then byte-compiles the file, notices
;;   `no-native-compile: t' and throws the result away
;;   (`comp--spill-lap-function' in comp.el), so no .eln is ever cached
;;   and the whole dance repeats next session.
;;
;; Denying JIT compilation for gzipped loaddefs skips the useless work
;; and the log buffer.  Nothing is lost: the compilation can never
;; produce a .eln anyway, and the deny list only affects deferred (JIT)
;; compilation, not explicit `native-compile' calls.
;;
;; Revisit after the next Emacs release: in emacs -Q (not --batch;
;; deferral is disabled when noninteractive), evaluate
;; (load "tramp-loaddefs"), wait a few seconds, and check whether the
;; *Async-native-compile-log* buffer appears.  If it no longer does,
;; delete this file and its `load' in init.el.

(setq native-comp-jit-compilation-deny-list '("-loaddefs\\.el\\.gz\\'"))

(when (> emacs-major-version 30)
  (display-warning
   'skip-loaddefs-native-comp
   "Emacs > 30 detected: check whether the loaddefs JIT-compilation bug \
is fixed and remove lisp/hacks/skip-loaddefs-native-comp.el"))

(provide 'skip-loaddefs-native-comp)
