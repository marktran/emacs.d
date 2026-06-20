(use-package ghostel
  :ensure t

  :custom
  (ghostel-kill-buffer-on-exit t)
  (ghostel-query-before-killing nil)
  (ghostel-term "xterm-ghostty")

  ;; Match the "iTerm2 Pastel Dark Background" Ghostty theme so
  ;; terminal colors (ls, prompts) match real Ghostty instead of
  ;; Emacs's stock `ansi-color-*' defaults.
  :custom-face
  (ghostel-color-black  ((t :foreground "#626262")))
  (ghostel-color-red    ((t :foreground "#ff8373")))
  (ghostel-color-green  ((t :foreground "#b4fb73")))
  (ghostel-color-yellow ((t :foreground "#fffdc3")))
  (ghostel-color-blue   ((t :foreground "#a5d5fe")))
  (ghostel-color-magenta ((t :foreground "#ff90fe")))
  (ghostel-color-cyan   ((t :foreground "#d1d1fe")))
  (ghostel-color-white  ((t :foreground "#f1f1f1")))
  (ghostel-color-bright-black  ((t :foreground "#8f8f8f")))
  (ghostel-color-bright-red    ((t :foreground "#ffc4be")))
  (ghostel-color-bright-green  ((t :foreground "#d6fcba")))
  (ghostel-color-bright-yellow ((t :foreground "#fffed5")))
  (ghostel-color-bright-blue   ((t :foreground "#c2e3ff")))
  (ghostel-color-bright-magenta ((t :foreground "#ffb2fe")))
  (ghostel-color-bright-cyan   ((t :foreground "#e6e6fe")))
  (ghostel-color-bright-white  ((t :foreground "#ffffff")))

  :general
  (:keymaps 'ghostel-semi-char-mode-map
   "C-g" 'keyboard-quit
   "<home>" 'beginning-of-buffer
   "<end>" 'end-of-buffer
   "<prior>" 'evil-scroll-up
   "<next>" 'evil-scroll-down
   "M-`" 'popper-cycle))
