(defun next-spec-day ()
  (remove-hook 'org-after-todo-state-change-hook 'next-spec-day)
  (org-todo 'nextset)
  (when (org-entry-get nil "NEXT-SPEC-DAY")
    (let ((types (if (org-entry-get nil "NEXT-SPEC-DAY-TYPE")
		     (split-string (org-entry-get nil "NEXT-SPEC-DAY-TYPE") " +")
		   '("SCHEDULED" "DEADLINE")))
	  (func (read-from-whole-string (org-entry-get nil "NEXT-SPEC-DAY"))))
      (dolist (type types)
	(when (stringp (org-entry-get nil type))
	  (let* ((time (org-entry-get nil type))
		 (suffix (and
			  (string-match "[ \t]*\\([-+]?[0-9]+[dwmy]\\)[ \t]*$" time)
			  (match-string 1 time)))
		 (pt (org-parse-time-string time)))
	    (incf (nth 3 pt))
	    (do nil
		((let* ((d (nth 3 pt))
			(m (nth 4 pt))
			(y (nth 5 pt))
			(date (list m d y))
			entry)
		   (eval func))
		 (funcall
		  (if (string= "DEADLINE" type)
		      'org-deadline
		    'org-schedule)
		  nil
		  (format-time-string (car org-time-stamp-formats) (apply 'encode-time pt))))
	      (incf (nth 3 pt))
	      (setf pt (decode-time (apply 'encode-time pt)))))))))
  (add-hook 'org-after-todo-state-change-hook 'next-spec-day))
(add-hook 'org-after-todo-state-change-hook 'next-spec-day)
