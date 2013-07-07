(defmacro gen-fill-keymap-hook (keymap &rest mappings)
  "Build fun that fills `KEYMAP' with `MAPPINGS'.
See `pour-mappings-to'."
  `(lambda () (fill-keymap ,keymap ,@mappings)))
