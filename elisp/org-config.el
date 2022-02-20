(require 'org)
(require 'org-agenda)

(org-clock-persistence-insinuate)
(setq org-todo-keyword-faces (quote (("TODO" :background "red3" :foreground "white" :weight bold)
                                     ("STARTED" :foreground "white" :background "green4" :weight bold)
                                     ("DONE" :foreground "white" :background "blue3" :weight bold)
                                     ("NOTE" :foreground "yellow" :background "blue3" :weight bold)
                                     ("NEXT" :foreground "brightyellow" :background "black" :weight bold)
                                     ("WAITING" :foreground "#d75f00" :background "black"))))

(setq org-todo-keywords '(
                          (sequence "TODO" "STARTED" "NEXT" "WAITING" "|" "DONE" "CNCL")
                          (sequence "NOTE")
                          ))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock)
(add-hook 'org-mode-hook (lambda () "" (whitespace-mode -1)))
(add-hook 'org-mode-hook 'org-indent-mode)

;; Prelude foists windmove onto everything which is nice except for
;; org mode, so this moves that aside in org mode, but org mode has a
;; way to pass along the keys which is nice.
(add-hook 'org-mode-hook (lambda () (windmove-default-keybindings 'super)))
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

(setq org-refile-targets '(
                           (org-agenda-files . (:todo . "STARTED"))
                           (org-agenda-files . (:todo . "NEXT"))
                           (org-agenda-files . (:tag . "refile"))
                           (org-agenda-files . (:todo . "TODO"))
                           ))

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
(global-set-key "\C-ca" 'org-agenda)

;; Can a DONE or CNCL still be scheduled? Or is that "impossible"?
(defun eej/find-stuck-projects ()
  ;; A project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO
  (let ((at-least-one-action (save-excursion (org-agenda-skip-subtree-if 'todo '("STARTED" "WAITING" "NEXT"))))
        (at-least-one-done (save-excursion (org-agenda-skip-subtree-if 'todo 'done)))
        (at-least-one-scheduled (save-excursion (org-agenda-skip-subtree-if 'scheduled))))
    (if (and at-least-one-done (not at-least-one-action) (not at-least-one-scheduled))
        nil
      (or (outline-next-heading) (org-end-of-subtree t)))))

(defun eej/find-nested-started ()
  ;; A project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO
  (if (not (org-goto-first-child))
      nil
    (let ((end (save-excursion (org-end-of-subtree t))))
      (if (re-search-forward "STARTED" end t)
          (progn (beginning-of-line) (point))
        (or (org-agenda-skip-subtree-if 'scheduled)
            (org-agenda-skip-subtree-if 'todo '("WAITING"))
            )))))

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

(defun eej/recompute-clock-sum ()
  "Recomputes the clock sum time for the projects buffer"
  (save-window-excursion
    ;; Is there a better way to find this buffer? Seems... clumsy
    (switch-to-buffer "projects.org<org>")
    (goto-char 1)
    (org-clock-sum (org-read-date nil nil "-3w"))))

(add-hook 'org-clock-out-hook 'eej/recompute-clock-sum)

;; I constantly have problems with the tags not being aligned, so for now
;; we will align the tags everytime we clock out.
(add-hook 'org-clock-out-hook 'org-align-all-tags)
(provide 'org-config)
