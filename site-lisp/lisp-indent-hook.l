;;;; -*- mode: lisp -*-
;;;;
;;;; lisp-indent-hook --- modify indentation for specific case.
;;;;
;;;; Author: bowbow99 <bowbow99@gmail.com>
;;;; Created: 2009-08-11 13:59:55
;;;; Updated: 2009-08-11 15:30:32
;;;;


(in-package "editor")

(defvar *lisp-indent-hook* nil)

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

(defun calc-lisp-indent (opoint)
  (let ((info (investigate-around opoint)))
    ;(msgbox "~{~S~%~}" info)
    (or (find-if (lambda (hook)
                   (save-excursion (funcall hook info)))
          *lisp-indent-hook*)
        (funcall +original-calc-lisp-indent+ opoint))))








;;;; lisp-indent-hook ends here