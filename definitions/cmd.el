(defmacro cmd (&rest code)
  "Macro for shorter keybindings."
  `(lambda ()
     (interactive)
     ,@code))
