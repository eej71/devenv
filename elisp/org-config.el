(require 'org)
(require 'org-agenda)

(org-clock-persistence-insinuate)
(setq org-todo-keyword-faces (quote (("TODO" :background "red3" :foreground "white" :weight bold)
                                     ("STARTED" :foreground "white" :background "green4" :weight bold)
                                     ("DONE" :foreground "white" :background "blue3" :weight bold)
                                     ("NOTE" :foreground "yellow" :background "blue3" :weight bold)
                                     ("OPS" :foreground "yellow3" :background "grey30" :weight bold)
                                     ("WAITING" :foreground "black" :background "yellow4")
                                     ("SOMEDAY" :foreground "magenta" :weight bold)
                                     ("CANCELLED" :foreground "forest green" :weight bold)
                                     )))

(setq org-todo-keywords '(
                          (sequence "TODO" "STARTED" "WAITING" "|" "DONE" "CNCL")
                          (sequence "NOTE")
                          (sequence "OPS")
                          (sequence "AGENDA" "DONE")))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock)
(add-hook 'org-mode-hook (lambda () "" (whitespace-mode -1)))
(add-hook 'org-mode-hook 'org-indent-mode)

(setq org-refile-targets '(
                           (org-agenda-files . (:todo . "STARTED"))
                           (org-agenda-files . (:todo . "TODO"))
                           (org-agenda-files . (:todo . "OPS"))))

(setq org-agenda-prefix-format
      '((agenda . "  %-12:c%?-12t% s")
        (timeline . "  % s")
        (todo . "  %-12:c")
        (tags . "  %-12:c")
        (search . "  %-12:c")))

(setq org-agenda-time-grid
      '((daily today require-timed) ""
        (500 800 900 930 1000 1030 1100 1130 1200 1300 1330 1400 1430 1500 1530 1600 1630 1700 1800)))

(org-defkey org-agenda-keymap "r" 'org-agenda-refile)
(define-key org-mode-map [(control x) up] 'org-metaup)
(define-key org-mode-map [(control x) down] 'org-metadown)
(define-key org-mode-map [(control x) left] 'org-metaleft)
(define-key org-mode-map [(control x) right] 'org-metaright)
(define-key global-map "\C-cc" 'org-capture)
(define-key global-map "\C-cr" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)

;; I want to find projects that look like this they had action in the past
;;   - action in the past means - DONE or CNCL
;;   - there are no further TODOs declared - so the project is stuck
(defun eej/has-done-cncl ()
  "Visits all the headlines in a tree looking for a WAITING or a STARTED"
  (let ((keyword (org-element-property ':todo-keyword (org-element-at-point))))
    (or (string-equal "DONE" keyword)
        (string-equal "CNCL" keyword)
        (and (outline-next-heading) (eej/has-done-cncl)))))

(defun eej/has-todo-started-waiting ()
  "Visits all the headlines in a tree looking for a WAITING or a STARTED"
  (let ((keyword (org-element-property ':todo-keyword (org-element-at-point)))
        (title (org-element-property ':title (org-element-at-point)))
        (scheduled (org-element-property ':scheduled (org-element-at-point)))
        (priority (org-element-property ':priority (org-element-at-point))))
    (or (and (or (equal priority 65) scheduled) (string-equal "TODO" keyword))
        (string-equal "STARTED" keyword)
        (string-equal "WAITING" keyword)
        (and (outline-next-heading) (eej/has-todo-started-waiting)))))

(defun eej/find-stuck-projects ()
  "A project is stuck if a given headline doesn't have any children WAITING or STARTED"
  (if (not (save-excursion (org-goto-first-child)))
      (org-end-of-subtree t)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (has-children (save-excursion (org-goto-first-child)))
           (next-headline (save-excursion (outline-next-heading)))

           ;; We don't have to skip our current line because we are a TODO
           (has-done-cncl (save-excursion
                            (save-restriction
                              (narrow-to-region (point) subtree-end)
                              (eej/has-done-cncl))))

           ;; This has to skip ahead to then search
           (has-todo-started-waiting (save-excursion
                                       (save-restriction
                                         (if (not (org-goto-first-child))
                                             nil
                                           (narrow-to-region (point) subtree-end)
                                           (eej/has-todo-started-waiting))))))
      (if (and has-done-cncl (not has-todo-started-waiting))
          nil
        next-headline))))

;; A bit sloppy as it doesn't look at actual attributes - recursive model above seems better
(defun eej/find-nested-started ()
  (let ((heading-end (save-excursion (outline-next-heading) (1- (point))))
        (has-children (save-excursion (org-goto-first-child)))
        has-started)
    (if has-children
        (let ((end (save-excursion (org-end-of-subtree t))))
          (save-excursion
            (outline-next-heading)
            (setq has-started (re-search-forward "STARTED" end t))
            (and has-started heading-end))))))

(setq org-clock-in-switch-to-state "STARTED")

;; These don't handle narrowed regions correctly
(add-hook 'org-create-file-search-functions  (lambda () (number-to-string (line-number-at-pos))))
(add-hook 'org-execute-file-search-functions (lambda (search-string) (goto-line (string-to-number search-string))))

;; Needed because indented levels in the clock table report (C-a r)
;; will display \\emsp and I can't figure out how to make it look
;; nice. So this is what it will be. Borrowed from this thread.
;; http://lists.gnu.org/archive/html/emacs-orgmode/2014-08/msg00974.html
(defun org-clocktable-indent-string (level)
  (if (= level 1) ""
    (let ((str " "))
      (dotimes (k (1- level) str)
        (setq str (concat "__" str))))))

(require 'org-jira)
(defun eej/post-worklog-to-jira ()
  "Post up time to jira"
  (interactive)
  ;; Get the jira ticket number
  (save-excursion
    (save-restriction
      (let* ((jira-ticket (or (org-entry-get (car org-clock-history) "JIRA-TICKET" t)
                              (read-string "JIRA Ticket: ")))
             (jira-title  (or (org-entry-get (car org-clock-history) "JIRA-TITLE" t) "Unknown"))
             (task-title  (progn
                            (org-goto-marker-or-bmk (car org-clock-history))
                            (org-element-property ':title (org-element-at-point))))
             (task-time-seconds (and org-clock-start-time (round (- (org-float-time) (org-float-time org-clock-start-time))))))
        (cond
         ;; We don't care about less than five minutes
         ((< task-time-seconds 300) t)
         ;; No ticket - so can't post
         ((not jira-ticket) (message "No JIRA Ticket - time lost"))
         (t (jiralib-add-worklog jira-ticket
                                 (jiralib-format-datetime)
                                 task-time-seconds
                                 (read-string (format "JIRA: [%s:%s] (%dm): " jira-ticket jira-title (/ task-time-seconds 60))
                                              task-title))))))))

(add-hook 'org-clock-out-hook 'eej/post-worklog-to-jira)

;; I constantly have problems with the tags not being aligned, so for now
;; we will align the tags everytime we clock out.
(add-hook 'org-clock-out-hook 'org-align-all-tags)
(provide 'org-config)
