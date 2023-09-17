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
(add-hook 'org-mode-hook (lambda () "" (org-indent-mode t)))

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


;; Determine if this is a todo category task (vs. done). Useful for org-map-entries.
(defun eej/is-todo-scheduled ()
  (let ((props (org-element-at-point)))
    (and (org-element-property ':scheduled props)
         (equal 'todo (org-element-property ':todo-type props))
         (point))))

;; Project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled todo
(defun eej/find-stuck-projects ()
  (let ((at-least-one-done (save-excursion (org-agenda-skip-subtree-if 'todo 'done))))
    (if (and at-least-one-done ;; This test is first because it frequently short ciruits the whole thing

             ;; at-least-one-action
             (not (save-excursion (org-agenda-skip-subtree-if 'todo '("STARTED" "WAITING" "NEXT"))))

             ;; at-least-one-scheduled todo (not scheduled done)
             (not (remove nil (org-map-entries #'eej/is-todo-scheduled t 'tree))))
        nil
      (or (outline-next-heading) (org-end-of-subtree t)))))

;; Find the nested most started headlines, but still include scheduled items
(defun eej/find-nested-started ()

  ;; First, we need to see if we have a child
  (let ((first-child (save-excursion (if (org-goto-first-child)
                                         (point)
                                       nil))))
    ;; If no children, then return nil because this headline is a keeper
    (if (not first-child) nil
      (let* (
             ;; Locate the end of this subtree
             (end (save-excursion (org-end-of-subtree t)))

             ;; Find the next scheduled child
             (scheduled-child (save-excursion
                                (goto-char first-child)
                                (car (remove nil (org-map-entries #'eej/is-todo-scheduled t 'tree)))))

             ;; Next started child in this tree
             (next-started (save-excursion
                             (goto-char first-child)
                             (if (re-search-forward "* STARTED" end t)
                                 (progn
                                   (beginning-of-line)
                                   (point))
                               nil)))

             ;; And of course locate a waiting task
             (next-waiting (save-excursion (org-agenda-skip-subtree-if 'todo '("WAITING")))))

        ;; If there's a scheduled child or a next started - visit the closer one
        (if (and next-started scheduled-child)
            (min next-started scheduled-child)

          ;; If not both, then either or if neither, then the end
          (or next-started scheduled-child (if next-waiting end nil)))
        ))))

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

(require 'org-duration)
(add-to-list 'load-path "~/.emacs.d/elpa/org-jira-20230413.441/" )
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
    (switch-to-buffer "projects.org")
    (goto-char 1)
    (org-clock-sum (org-read-date nil nil "-3w"))))

(add-hook 'org-clock-out-hook 'eej/recompute-clock-sum)


;; Prelude foists windmove onto everything which is nice except for
;; org mode, so we make a special minor keymode map which will be
;; added to org mode files which will then nuke the windmove
;; mapping. But, we still fallback to windmove thanks to the magic of
;; orgmode hooks.
(defvar eej-org-mode-map (make-sparse-keymap) "Keymap for eej-org-mode-map")
(define-minor-mode eej-org-mode
  "A minor mode to bring the shift arrows keys with windmove mode active"
  :init-value nil
  :keymap eej-org-mode-map)

(define-key eej-org-mode-map (kbd "S-<down>") #'org-shiftdown)
(define-key eej-org-mode-map (kbd "S-<left>") #'org-shiftleft)
(define-key eej-org-mode-map (kbd "S-<right>") #'org-shiftright)
(define-key eej-org-mode-map (kbd "S-<up>") #'org-shiftup)

(add-hook 'org-mode-hook 'eej-org-mode)
;;(add-hook 'org-super-agenda-mode-hook 'eej-org-mode)
;;(add-hook 'org-agenda-mode-hook 'eej-org-mode)

(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

;; I constantly have problems with the tags not being aligned, so for now
;; we will align the tags everytime we clock out.
(add-hook 'org-clock-out-hook 'org-align-all-tags)
(provide 'org-config)
