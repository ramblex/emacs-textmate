Emacs textmate
==============

This package gives some of the functionality provided by TextMate to Emacs.
In particular, the automatic insertion of braces and string delimiters. It is
heavily based on work by Orestis Markou 
(http://code.google.com/p/emacs-textmate/).

Other features include the option to bind goto-line to `\M-l` and
open-next-line - which allows you to easily start a new line from anywhere on
the current line - to `\M-\r`.

The package also allows the option to emulate vim's softtabstop which deletes
back to the previous column of whitespace or as much whitespace as possible, or
just one char if that's not possible.

Installation
------------

The following gives a basic setup procedure to get emacs-textmate up and running

1. Obtain the source code (`git clone git://github.com/ramblex/emacs-textmate.git`)
2. Move the emacs-textmate directory to somewhere sensible e.g. ~/.emacs.d/
3. Add the following to your .emacs:

        (add-to-list 'load-path "~/.emacs.d/emacs-textmate")
        (require 'textmate)
        (tm/initialize)


Defaults
--------

- goto-line is turned off since `\M-l` is bound to lower-case by
  default.  
- `\M-\r` is bound to open-next-line.
- vim softtabstop is turned off by default.
- '{', '[', '"' and '(' are auto-inserted by default in all modes
-  "'" is inserted by default in all modes except emacs-lisp-mode, lisp-mode
   and lisp-interaction-mode. To change this, customise the 
   tm/exempt-quote-modes variable.

There is also the option of turning off some of the functionality for some 
modes. For example, in lisp-mode, having ' turn into '' is highly annoying
so this is turned off automatically.

Customisation
-------------

You can customize the package by using `M-x customize-group textmate`
