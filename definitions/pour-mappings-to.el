(defun pour-mappings-to (map mappings)
  "Calls `set-key' with `map' on every key-fun pair in `MAPPINGS'.
`MAPPINGS' is a list of string-fun pairs, with a `READ-KBD-MACRO'-readable string and a interactive-fun."
  (dolist (mapping (group mappings 2))
    (set-key map (car mapping) (cadr mapping)))
  map)
