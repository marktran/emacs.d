## Emacs Lisp
- Do not add `;;; Commentary:` sections or `;;; <file>.el ends here` EOF comments.
- Every `.el` file must start with a `lexical-binding: t` cookie: either
  `;;; -*- lexical-binding: t; -*-` on its own, or appended to an existing
  `;;; <file>.el --- <description>` first line.
- Do not leave generated `*.elc` files in this repo. When byte-compiling for validation, write output to a temporary directory or remove it immediately afterward.
