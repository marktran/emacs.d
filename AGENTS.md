## Emacs Lisp
- Do not add `;;; Commentary:` sections, `;;; <file>.el ends here` EOF comments, or lexical-binding file headers.
- Do not leave generated `*.elc` files in this repo. When byte-compiling for validation, write output to a temporary directory or remove it immediately afterward.
