;;;; -*- mode: lisp -*-
;;;;
;;;; lisp-indent-hook/flet-like.l --- indentation for flet like forms.
;;;;
;;;; Author: bowbow99 <bowbow99@gmail.com>
;;;; Created: 2009-08-11 16:12:50
;;;; Updated: 2009-08-11 17:29:09
;;;;
#|
引数をもうちょっとインデントする
(flet ((example-of-local-function-with-ridiculously-long-name
           (arg1 arg2 &optional arg3)
         ...))
  ...)

let の値をもうちょっとインデントする。変数名と値を区別しやすい。
(let ((local-symbol-with-extreamly-long-name
          (value of (first local symbol)))
      (another-symbol-also-too-long-to-put-value-right-after
          (another-value)))
  ...)
|#

(require "lisp-indent-hook")

(in-package "editor")

(dolist (sym '(let let*))
  (setf (get sym 'lisp-indent-flet) t))

(add-hook '*lisp-indent-hook*
  (defun calc-lisp-indent-flet (info)
    (use-sexp-info-accessors
     (with-places (first second third) info
       (when (and (> (length info) 3)
                  (let ((sym (find-symbol (symbol-of third))))
                    (when sym (get sym 'lisp-indent-flet)))
                  (equal (symbol-of second) ""))
         (+ (column-of first)
            (if (= (nth-arg first) 1) 4 2)))))))

(provide "lisp-indent-hook/flet-like.l")

;;;; lisp-indent-hook/flet-like.l ends here
