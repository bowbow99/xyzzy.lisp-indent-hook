;;;; -*- mode: lisp -*-
;;;;
;;;; lisp-indent-hook --- modify indentation for specific case.
;;;;
;;;; Author: bowbow99 <bowbow99@gmail.com>
;;;; Created: 2009-08-11 13:59:55
;;;; Updated: 2009-08-11 17:29:17
;;;;


(in-package "editor")

(export '(*lisp-indent-hook*))

(defvar *lisp-indent-hook* nil
  "*Hook for modifying indentation for specific case.

   when a one of the hook'ed function return a number, it will be
 used as indent-level.
   hook'ed function will recieve a list, each element contains info
 on each sexp wrapping around:
 - operator as string
 - point of where the sexp starts
 - column of where sexp starts
 - what number a operand right after original point is in the sexp")

(defconstant +original-calc-lisp-indent+ #'ed::calc-lisp-indent
  "Original calc-lisp-indent function.")

(defun following-symbol (&optional from)
  (save-excursion
    (when from (goto-char from))
    (buffer-substring (progn (skip-syntax-spec-backward "w_") (point))
                      (progn (skip-syntax-spec-forward "w_") (point)))))

(defun investigate-sexp (opoint &optional start)
  (save-excursion
    (if start (goto-char start) (setq start (point)))
    (let ((operator (following-symbol (1+ start))))
      (list operator (point) (current-column)
            (let ((n 0))
              (goto-char (+ start 1 (length operator)))
              (ignore-errors
                 (while (<= (point) opoint)
                   (incf n)
                   (forward-sexp 1)))
              n)))))

(defun investigate-around (&optional opoint)
  (save-excursion
    (if opoint (goto-char opoint) (setq opoint (point)))
    (let ((info nil))
      (while (up-list -1 t)
        (push (investigate-sexp opoint (point)) info))
      (nreverse info))))

;;; overriding built-in function ed::calc-lisp-indent
(defun calc-lisp-indent (opoint)
  (let ((info (investigate-around opoint)))
    (or (some (lambda (hook)
                (save-excursion
                  (let ((ret (funcall hook info)))
                    (when (numberp ret) ret))))
          *lisp-indent-hook*)
        (funcall +original-calc-lisp-indent+ opoint))))


;;;;
;;;; * utilities: maybe useful for hook functions
;;;;
#| EXAMPLE:
(add-hook '*lisp-indent-hook
  (defun magical-indent (info)
    (use-sexp-info-accessors
     (with-places (first second third) info
       ;; now you can refer column of second wrapping form by following :)
       (column-of second)
       ...))))

to see more example, check sample configs under lisp-indent-hook folder.
|#
(defmacro with-places (places object &body body)
  (let ((obj (gensym)))
    `(let ((,obj ,object))
       (let ,(mapcar (lambda (place)
                       `(,place (,place ,obj)))
               places)
         ,@body))))
(setf (get 'with-places 'lisp-indent-hook) 2)

(defmacro use-sexp-info-accessors (&body body)
  `(labels ((symbol-of (info) (first info))
            (point-of (info) (second info))
            (column-of (info) (third info))
            (nth-arg (info) (fourth info)))
     ,@body))

;;;; lisp-indent-hook ends here
