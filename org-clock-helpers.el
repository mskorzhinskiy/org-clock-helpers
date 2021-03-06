;;; org-clock-helpers.el --- helper functions to automate clock insertion -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2021 Mikhail Skorzhisnkii
;;
;; Author: Mikhail Skorzhisnkii <http://github/rasmi>
;; Maintainer: Mikhail Skorzhisnkii <mskorzhinskiy@eml.cc>
;; Created: January 05, 2021
;; Modified: January 05, 2021
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/rasmi/org-clock-helpers
;; Package-Requires: ((emacs 27.1) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;
;;
;;; Code:
(require 'org)
(require 'org-clock)

;;
;; Insert past clocks for appointments
;;

(defcustom org-clock-helpers-appt-clock-keywords org-done-keywords
  "A list of keywrods triggering insertion of clock entry.

Useful if you don't want to insert clock for some of the
keywords, for example if you don't want to insert clock for
cancelled appointments, mark item as DONT."
  :group 'org-clock
  :type '(list string))

(defun org-clock-helpers-insert-appt-clock (change-plist)
  "Insert appointmnet clock to the current task depending on its time.

This function is meant to be called only as a hook function for
task trigger hook and CHANGE-PLIST contains a description of what
have been done."
  (when (member (plist-get change-plist :to) org-clock-helpers-appt-clock-keywords)
    (let* ((scheduled (org-entry-get nil "SCHEDULED"))
           (ts (org-timestamp-from-string scheduled))
           (start (org-timestamp-to-time ts nil))
           (end (org-timestamp-to-time ts t)))
      (when (and scheduled
                 ;; indication that task has no end
                 (not (= (time-to-seconds start) (time-to-seconds end))))
        (org-clock-in nil start)
        (org-clock-out nil nil end)))))

;;;###autoload
(defun org-clock-helpers-appt-clock-load ()
  "Install clocking hook."
  (add-hook 'org-trigger-hook
            #'org-clock-helpers-insert-appt-clock))

;;;###autoload
(defun org-clock-helpers-appt-clock-unload ()
  "Uninstall clocking hook."
  (remove-hook 'org-trigger-hook
               #'org-clock-helpers-insert-appt-clock))

;;
;; Freely insert past clocks
;;

(defvar org-past-clock-stored nil)

;;;###autoload
(defun org-insert-past-clock ()
  "Insert past clock to the current task.

Caution: this will cancel current clock. There is no easy way
around this."
  (interactive)
  (let* ((start (org-read-date t t nil nil
                               org-past-clock-stored))
         (duration (read-string "Duration: "))
         (minutes (* 60 (org-duration-to-minutes duration))))
    (org-clock-in nil start)
    (org-clock-out nil nil (time-add start
                                     (seconds-to-time minutes)))
    (setq org-past-clock-stored start)))

(provide 'org-clock-helpers)
;;; org-clock-helpers.el ends here
