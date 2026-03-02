;;; org-custom.el --- Org mode customizations -*- lexical-binding: t; -*-
;;
;;
;;; Commentary:
;; Custom functions and utilities for Org mode

;;; Code:

(require 'seq)

(defun spectral-org-setup ()
  "Initialize our org mode buffers."
  (turn-on-font-lock)
  (org-indent-mode t)
  (whitespace-mode -1))

(defun spectral-org-todo-order-sort (orig-fun &rest args)
  "Fix up `org-todo-keywords-1' before calling ORIG-FUN with ARGS.
This cleans up my todo sorting."
  (let ((org-todo-keywords-1 '("STARTED" "TODO" "NEXT" "WAITING" "DONE" "CNCL" "NOTE")))
    (apply orig-fun args)))

(defun spectral-org-create-file-search ()
  "Return an Org file search string for the current line."
  (number-to-string (line-number-at-pos)))

(defun spectral-org-execute-file-search (search-string)
  "Jump to the Org line encoded by SEARCH-STRING."
  (goto-char (point-min))
  (forward-line (max 0 (1- (string-to-number search-string)))))

(defun eej/find-stuck-projects ()
  "Find projects with at least one DONE task but no active tasks.
A project has at least one DONE task and no child STARTED|WAITING|NEXT
or any scheduled TODO."
  (let ((at-least-one-action (save-excursion (org-agenda-skip-subtree-if 'todo '("STARTED" "WAITING" "NEXT"))))
        (at-least-one-done (save-excursion (org-agenda-skip-subtree-if 'todo 'done)))
        (at-least-one-scheduled (save-excursion (seq-some #'identity (org-map-entries #'eej/is-todo-scheduled t 'tree)))))
    (if (and at-least-one-done (not at-least-one-action) (not at-least-one-scheduled))
        nil
      (or (outline-next-heading) (org-end-of-subtree t)))))

(defun eej/is-todo-scheduled ()
  "Is this an incomplete todo with a scheduled date."
  (let* ((element (org-element-at-point))
         (todo-type (org-element-property :todo-type element))
         (scheduled (org-element-property :scheduled element)))
    (and (eq todo-type 'todo) scheduled (point))))

(defun eej/find-nested-started ()
  "Find nested STARTED tasks.
Has >1 DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO."
  (if (not (org-goto-first-child))
      nil
    (let ((end (save-excursion (org-end-of-subtree t))))
      (if (re-search-forward "STARTED" end t)
          (progn (beginning-of-line) (point))
        (or
         (org-agenda-skip-subtree-if 'todo '("WAITING"))
         (seq-some #'identity (org-map-entries #'eej/is-todo-scheduled t 'tree)))))))

(defun org-clocktable-indent-string (level)
  "Improve the formatting of the clocktable for a given LEVEL."
  (if (= level 1) ""
    (let ((str " "))
      (dotimes (_ (1- level) str)
        (setq str (concat "__" str))))))



(defun spectral-recompute-clock-sum ()
  "Recomputes the clock sum time for the projects buffer."
  (let ((projects-file (expand-file-name "projects.org" org-directory)))
    (when (file-exists-p projects-file)
      (with-current-buffer (find-file-noselect projects-file)
        (save-restriction
          (widen)
          (org-align-all-tags)
          (org-clock-sum (org-read-date nil nil "-21d")
                         (org-read-date nil nil "now")))
        (save-buffer)
        (message "Recomputed clocks for projects.org")))))

(advice-add 'org-sort-entries :around #'spectral-org-todo-order-sort)

;; TODO: consult-org-heading or consult-org-agenda
(use-package org
  ;; It's necessary to place everything in :config otherwise org mode loading is sad
  :init
  (setq org-replace-disputed-keys t)
  :config
  (setq org-adapt-indentation t
        org-agenda-block-separator ""
        org-agenda-files '("~/org/projects.org")
        org-agenda-log-mode-add-notes nil
        org-agenda-log-mode-items '(clock)
        org-agenda-prefix-format '((agenda . "  %-12:c%?-12t% s")
                                   (timeline . "  % s")
                                   (todo . "  %-12:c")
                                   (tags . "  %-12:c")
                                   (search . "  %-12:c"))
        org-agenda-remove-tags t
        org-agenda-sorting-strategy '((agenda habit-down time-up priority-down category-keep)
                                      (todo todo-state-down priority-down category-keep)
                                      (tags priority-down category-keep)
                                      (search category-keep))
        org-agenda-start-with-clockreport-mode t
        org-agenda-tags-column 150
        org-agenda-time-grid '((daily today require-timed) ""
                               (500 800 900 930 1000 1030 1100 1130 1200 1300 1330 1400 1430 1500 1530 1600 1630 1700 1800))
        org-babel-load-languages '((emacs-lisp . t) (sql . t))
        org-checkbox-hierarchical-statistics nil
        org-clock-history-length 25
        org-clock-in-switch-to-state "STARTED"
        org-clock-into-drawer t
        org-clock-mode-line-total 'today
        org-clock-out-remove-zero-time-clocks t
        org-clock-persist t
        org-clock-persist-file "~/org/org-clock-save.el"
        org-clock-sound t
        org-columns-default-format "%100ITEM %TODO %TAGS"
        org-deadline-warning-days 3
        org-directory "~/org"
        org-default-notes-file (concat org-directory "/notes.org")
        org-enforce-todo-dependencies t
        org-hide-leading-stars t
        org-log-done 'time
        org-log-into-drawer t
        org-log-note-clock-out nil
        org-outline-path-complete-in-steps nil
        org-refile-use-outline-path t
        org-return-follows-link t
        org-reverse-note-order t
        org-startup-indented t
        org-tags-column 120
        org-tags-match-list-sublevels t
        ;; If you change the keywords here, update `spectral-org-todo-order-sort`.
        org-todo-keywords '((sequence "TODO" "STARTED" "NEXT" "WAITING" "|" "DONE" "CNCL")
                            (sequence "NOTE"))
        org-todo-keyword-faces '(("TODO" . org-todo-todo)
                                 ("STARTED" . org-todo-started)
                                 ("DONE" . org-todo-done)
                                 ("NOTE" . org-todo-note)
                                 ("NEXT" . org-todo-next)
                                 ("WAITING" . org-todo-waiting))
        org-use-speed-commands t
        org-use-tag-inheritance t
        fill-column 90
        org-time-clocksum-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t)
        org-refile-targets '((org-agenda-files . (:todo . "STARTED"))
                             (org-agenda-files . (:todo . "NEXT"))
                             (org-agenda-files . (:tag . "refile"))
                             (org-agenda-files . (:todo . "TODO"))))
  (org-clock-persistence-insinuate)
  (add-hook 'org-mode-hook #'spectral-org-setup)
  (add-hook 'org-clock-out-hook #'spectral-recompute-clock-sum)
  (add-hook 'org-mode-hook #'visual-line-mode)
  (add-hook 'org-shiftup-final-hook #'windmove-up)
  (add-hook 'org-shiftleft-final-hook #'windmove-left)
  (add-hook 'org-shiftdown-final-hook #'windmove-down)
  (add-hook 'org-shiftright-final-hook #'windmove-right)
  (add-hook 'org-create-file-search-functions #'spectral-org-create-file-search)
  (add-hook 'org-execute-file-search-functions #'spectral-org-execute-file-search)
  :bind
  (("C-c a" . org-agenda)
   ("C-c c" . org-capture)
   :map org-mode-map
   ("C-x <up>" . org-metaup)
   ("C-x <down>" . org-metadown)
   ("C-x <left>" . org-metaleft)
   ("C-x <right>" . org-metaright)))

(use-package org-jira
  ;; It's necessary to place everything in :config otherwise org-jira is sad
  :config
  ;; (add-hook 'org-clock-out-hook #'eej/post-worklog-to-jira)
  (let ((jira-token (or (getenv "JIRALIB_ATLASSIAN_CLOUD_TOKEN")
                        (bound-and-true-p jiralib-atlassian-cloud-token))))
    (setq jiralib-url "https://gtsjira.atlassian.net"
          request-log-level 'debug
          url-debug t
          jiralib-user-login-name "ejohnson@example.com"
          jiralib-atlassian-cloud-token jira-token
          jiralib-token (when jira-token
                          `("Authorization" . ,(format "Basic %s"
                                                       (base64-encode-string
                                                        (concat jiralib-user-login-name ":" jira-token) t)))))))

(use-package org-super-agenda)

(use-package visual-fill-column
  :straight t
  :hook (org-mode . visual-fill-column-mode)
  :custom
  (visual-fill-column-width 150)
  (visual-fill-column-enable-sensible-window-split t)
  :config
  (add-hook 'visual-fill-column-mode-hook #'visual-line-mode))

(provide 'org-custom)
;;; org-custom.el ends here
