;; textmate.el --- TextMate behaviour on Emacs
;; Copyright (C) 2008  Orestis Markou
;; (Modified by Alex Duller 2009)

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 2
;; of the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
;;
;;

;;; Commentary:

;;
;; Basic steps to setup:
;;   1. Place `textmate.el' in your `load-path'.
;;   2. In your .emacs file:
;;        (require 'textmate)
;;        (tm/initialize)
;;
;; You can file issues, send comments and get the latest version at:
;; http://code.google.com/p/emacs-textmate/
;;
;; Contributions welcome!

;;; Code:

(eval-when-compile (require 'cl))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User customizable variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgroup textmate ()
  "Textmate minor mode"
  :group 'editor)

(defcustom tm/use-tm-goto-line nil
  "If set to t, use M-l to go to line"
  :type 'boolean
  :group 'textmate)

(defcustom tm/backspace-delete-column nil
  "If set to t, backspace will delete a block os spaces based on tab-width"
  :type 'boolean
  :group 'textmate)

(defcustom tm/dont-activate nil
  "If set to t, don't activate tm/minor-mode automatically."
  :type 'boolean
  :group 'textmate)
(make-variable-buffer-local 'tm/dont-activate)

(defcustom tm/use-newline-and-indent nil
  "If set to t, use newline-and-indent for [return key]."
  :type 'boolean
  :group 'textmate)

(defcustom tm/exempt-quote-modes '(emacs-lisp-mode
                                   lisp-mode
                                   lisp-interaction-mode)
  "Modes which in which to not auto-insert a quote"
  :type '(repeat symbol)
  :group 'textmate)

(defun tm/initialize ()
  "Do the necessary initialization"
  (add-hook 'after-change-major-mode-hook
            'tm/minor-mode-auto-on))

(defun tm/minor-mode-auto-on ()
  "Turn on TM minor mode unless `tm/dont-activate' is set to t."
  (unless tm/dont-activate
    (tm/minor-mode-on)))

(defun tm/minor-mode-on ()
  (interactive)
  (tm/minor-mode 1))

(defun tm/minor-mode-off ()
  (interactive)
  (tm/minor-mode nil))

(define-minor-mode tm/minor-mode
  "Toggle Textmate mode.
     With no argument, this command toggles the mode.
     Non-null prefix argument turns on the mode.
     Null prefix argument turns off the mode."
  ;; The initial value.
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " TM"
  ;; The minor mode bindings.
  :keymap '(([backspace] . tm/backspace)
            ("\"" . tm/move-over-dbl-quote)
            ("\'" . tm/move-over-quote)
            (")" . tm/move-over-bracket)
            ("]" . tm/move-over-square)
            ("}" . tm/move-over-curly)
            ("[" . tm/insert-brace)
            ("(" . tm/insert-brace)
            ("{" . tm/insert-brace)
            ;; Duplicate TextMate's auto-indent
            ([return] . tm/newline-and-indent)
            ;; Duplicate TextMate's command-return
            ("\M-\r" . tm/open-next-line)
            ;; Duplicate TextMate's goto line
            ("\M-l" . goto-line))
  :group 'textmate
  (progn
    (setq skeleton-pair t)))

(defun tm/newline-and-indent ()
  "Enable users to decide whether or not to use newline-and-indent"
  (interactive)
  (if (eq tm/use-newline-and-indent t)
      (newline-and-indent)
    (newline)))

(defun tm/open-next-line()
  "Function to open and goto indented next line"
  (interactive)
  (move-end-of-line nil)
  (tm/newline-and-indent))

;; The pairs that are supported by this mode
(setq textmate-pairs '(( ?\( . ?\) )
                       (  ?\' . ?\' )
                       (  ?\" . ?\" )
                       (  ?[ . ?] )
                       (  ?{ . ?} )))

(defun tm/is-empty-pair ()
  "Check if a pair are next to each other. This is used to allow easy deletion"
  (interactive)
  (eq (cdr (assoc (char-before)  textmate-pairs)) (char-after)))
;; Thanks to Trey Jackson
;; http://stackoverflow.com/questions/1450169/how-do-i-emulate-vims-softtabstop-in-emacs/1450454#1450454
(defun tm/backward-delete-whitespace-to-column ()
  "delete back to the previous column of whitespace, or as much whitespace as possible,
or just one char if that's not possible"
  (interactive)
  (if indent-tabs-mode
      (call-interactively 'backward-delete-char-untabify)
    (let ((movement (% (current-column) tab-width))
          (p (point)))
      (when (= movement 0) (setq movement tab-width))
      (save-match-data
        (if (string-match "\\w*\\(\\s-+\\)$" (buffer-substring-no-properties (- p movement) p))
            (backward-delete-char-untabify (- (match-end 1) (match-beginning 1)))
        (call-interactively 'backward-delete-char-untabify))))))

(defun tm/backspace ()
  (interactive)
  (if (eq (char-after) nil)
      nil   ;; if char-after is nil, just backspace
    (if (tm/is-empty-pair)
        (delete-char 1)))
  (if (eq tm/backspace-delete-column t)
      (tm/backward-delete-whitespace-to-column)
    (delete-backward-char 1)))

;; These are used when user has manually inserted the trailing char of a pair
(setq pushovers
      '((?\" . (lambda () (forward-char 1) ))
        (?\' . (lambda () (forward-char 1) ))
        (?\) . (lambda () (up-list 1) ))
        (?\] . (lambda () (up-list 1) ))
        (?\} . (lambda () (up-list 1) ))))

(setq defaults
      '((?\" . (lambda () (skeleton-pair-insert-maybe nil)))
        (?\' . (lambda () (skeleton-pair-insert-maybe nil)))
        (?\) . (lambda () (insert-char ?\) 1) ))
        (?\] . (lambda () (insert-char ?\] 1) ))
        (?\} . (lambda () (insert-char ?\} 1) ))))

(defun tm/move-over (char)
  "If the user has manually inserted the trailing char, don't insert another
   one"
  (if (eq (char-after) char)
      (funcall (cdr (assoc char pushovers)))
    (funcall (cdr (assoc char defaults))))
  (indent-according-to-mode))

(defun tm/insert-brace ()
  (interactive)
  (skeleton-pair-insert-maybe nil)
  (indent-according-to-mode))

(defun tm/move-over-bracket ()  (interactive)(tm/move-over ?\)))
(defun tm/move-over-curly ()  (interactive)(tm/move-over ?\}))
(defun tm/move-over-square ()  (interactive)(tm/move-over ?\]))
(defun tm/move-over-quote ()
  (interactive)
  (if (eq (member major-mode tm/exempt-quote-modes) nil)
      (tm/move-over ?\')
    (insert-char ?\' 1)))
(defun tm/move-over-dbl-quote ()  (interactive)(tm/move-over ?\"))

(provide 'textmate)
