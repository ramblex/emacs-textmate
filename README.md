h1. Emacs textmate

This package gives some of the functionality provided by TextMate to Emacs.
In particular, the automatic insertion of braces and string delimiters. It is
heavily based on work by Orestis Markou 
(http://code.google.com/p/emacs-textmate/).

There is also the option of turning off some of the functionality for some 
modes. For example, in lisp-mode, having ' turn into '' is highly annoying
so this is turned off automatically.

h2. Installation

The following gives a basic setup procedure to get emacs-textmate up and running
. Obtain the source code (git clone git://github.com/ramblex/emacs-textmate.git)
. Move the emacs-textmate directory to somewhere sensible e.g. ~/.emacs.d/
. Add the following to your .emacs:
  pre. (add-to-list 'load-path "~/.emacs.d/emacs-textmate")
       (require 'textmate)
       (tm/initialize)

You can customize the package by using @M-x customize-group textmate@
