;;; org-custom.el --- Org mode customizations -*- lexical-binding: t; -*-
;;
;;
;;; Commentary:
;; Custom functions and utilities for Org mode

;;; Code:

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

(defun eej/org--subtree-end ()
  "Return the end position of the current subtree."
  (save-excursion
    (org-back-to-heading t)
    (org-end-of-subtree t t)))

(defun eej/org--next-heading-or-eob ()
  "Return next heading position, or end of buffer when no heading remains."
  (save-excursion
    (or (outline-next-heading) (point-max))))

(defun eej/org--future-time-p (time-value)
  "Return non-nil when TIME-VALUE exists and is in the future."
  (and time-value (time-less-p (current-time) time-value)))

(defun eej/org--todo-scheduled-p ()
  "Return non-nil when current TODO heading has a SCHEDULED timestamp."
  (save-excursion
    (org-back-to-heading t)
    (let ((planning-end (line-end-position 2)))
      (forward-line 1)
      (re-search-forward org-scheduled-time-regexp planning-end t))))

(defun eej/org--project-descendant-flags ()
  "Return (HAS-FINAL . HAS-ACTIVE) for descendants in current subtree."
  (save-excursion
    (org-back-to-heading t)
    (let ((subtree-end (eej/org--subtree-end))
          has-final
          has-active
          state)
      (when (org-goto-first-child)
        (while (and (< (point) subtree-end)
                    (not (and has-final has-active)))
          (setq state (org-get-todo-state))
          (cond
           ((or (equal state "DONE") (equal state "CNCL"))
            (setq has-final t))
           ((or (equal state "STARTED")
                (equal state "WAITING")
                (equal state "NEXT"))
            (setq has-active t))
           ((and (equal state "TODO")
                 (eej/org--todo-scheduled-p))
            (setq has-active t)))
          (outline-next-heading)))
      (cons has-final has-active))))

(defun eej/org--subtree-has-descendant-project-p ()
  "Return non-nil when subtree has a descendant TODO with a final descendant.

This is used to keep only the bottom-most stuck project in a TODO lineage."
  (save-excursion
    (org-back-to-heading t)
    (let ((subtree-end (eej/org--subtree-end))
          (todo-level-stack nil)
          state
          level
          found)
      (when (org-goto-first-child)
        (while (and (not found)
                    (< (point) subtree-end))
          (setq level (org-outline-level))
          ;; Keep only TODO ancestors of the current heading.
          (while (and todo-level-stack
                      (>= (car todo-level-stack) level))
            (pop todo-level-stack))
          (setq state (org-get-todo-state))
          (cond
           ((equal state "TODO")
            (push level todo-level-stack))
           ((or (equal state "DONE") (equal state "CNCL"))
            (when todo-level-stack
              (setq found t))))
          (outline-next-heading)))
      found)))

(defun eej/org--subtree-has-actionable-started-descendant-p ()
  "Return non-nil when descendants contain actionable STARTED heading."
  (save-excursion
    (org-back-to-heading t)
    (let ((subtree-end (eej/org--subtree-end))
          found
          scheduled)
      (when (org-goto-first-child)
        (while (and (not found)
                    (re-search-forward "^[*]+[ \t]+STARTED\\_>" subtree-end t))
          (goto-char (line-beginning-position))
          (setq scheduled (org-get-scheduled-time (point)))
          (setq found (not (eej/org--future-time-p scheduled)))
          (unless found
            (outline-next-heading))))
      found)))

(defun eej/find-stuck-projects ()
  "Keep bottom-most TODO projects that are stuck.

Project qualification is subtree-wide (any DONE/CNCL descendant).
Active descendants are STARTED/WAITING/NEXT, or TODO with any SCHEDULED date.

When both parent and child are stuck, only the child (bottom-most) is kept.
This skip function is intended for a `todo \"TODO\"' matcher."
  (let* ((subtree-end (eej/org--subtree-end))
         (state (org-get-todo-state))
         (flags (and (equal state "TODO")
                     (eej/org--project-descendant-flags)))
         (has-final (car flags))
         (has-active (cdr flags)))
    (cond
     ;; Safety fallback for non-TODO callers.
     ((not flags) subtree-end)
     ;; No final descendants means no descendant can qualify as a project.
     (has-final
      (cond
       ;; Active descendants can exist on a sibling branch; keep descending.
       (has-active (eej/org--next-heading-or-eob))
       ;; Current is stuck but not leaf-most; keep descending to find leaf-most.
       ((eej/org--subtree-has-descendant-project-p) (eej/org--next-heading-or-eob))
       ;; Leaf-most stuck project: keep it.
       (t nil)))
     ;; No finals anywhere below: prune subtree.
     (t subtree-end))))

(defun eej/find-nested-started ()
  "Skip non-actionable review entries and non-deepest actionable STARTED entries.

Review-actionable entries are:
- TODO with SCHEDULED date that is not in the future.
- STARTED that is not scheduled in the future.

For STARTED entries, only the deepest actionable STARTED in a subtree is kept.
This skip function is intended for a `todo \"TODO|STARTED\"' matcher."
  (let ((state (org-get-todo-state))
        scheduled)
    (cond
     ((equal state "TODO")
      (setq scheduled (org-get-scheduled-time (point)))
      (if (and scheduled
               (not (eej/org--future-time-p scheduled)))
          nil
        (eej/org--next-heading-or-eob)))
     ((equal state "STARTED")
      (setq scheduled (org-get-scheduled-time (point)))
      (if (or (eej/org--future-time-p scheduled)
              (eej/org--subtree-has-actionable-started-descendant-p))
          (eej/org--next-heading-or-eob)
        nil))
     (t (eej/org--next-heading-or-eob)))))

(defun eej/skip-future-scheduled ()
  "Skip current heading when it is scheduled in the future."
  (if (eej/org--future-time-p (org-get-scheduled-time (point)))
      (eej/org--next-heading-or-eob)
    nil))

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

;;; Capture <-> Clock bidirectional linking
;;
;; For configured capture keys, when a task is clocked in:
;;   - The captured entry gets a CLOCK-TASK property linking to the task
;;   - The clocked task gets a backlink property (e.g. JOURNAL, REFERENCES)
;;     linking to the captured entry

(defun eej/clock-task-id-link ()
  "Return an `id:' Org link to the currently clocked task.
Ensures the clocked task has a persistent org-id, creating one if
needed, so the link survives heading moves and refiles."
  (if (org-clocking-p)
      (org-with-point-at org-clock-marker
        (org-id-get-create)
        (format "[[id:%s][%s]]"
                (org-id-get)
                (org-get-heading t t t t)))
    ""))

(defun eej/capture-template-journal ()
  "Capture template for journal entries."
  (if (org-clocking-p)
      "* %U %?\n:PROPERTIES:\n:CLOCK-TASK: %(eej/clock-task-id-link)\n:END:\n"
    "* %U %?\n"))

(defun eej/capture-template-reference ()
  "Capture template for references."
  (if (org-clocking-p)
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:SOURCE: %^{Source|}\n:CLOCK-TASK: %(eej/clock-task-id-link)\n:END:\n"
    "* %?\n:PROPERTIES:\n:CREATED: %U\n:SOURCE: %^{Source|}\n:END:\n"))

(defun eej/capture-template-bookmark ()
  "Capture template for bookmarks."
  (if (org-clocking-p)
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:URL: %^{URL}\n:CLOCK-TASK: %(eej/clock-task-id-link)\n:END:\n"
    "* %?\n:PROPERTIES:\n:CREATED: %U\n:URL: %^{URL}\n:END:\n"))

(defun eej/capture-template-snippet ()
  "Capture template for code snippets."
  (if (org-clocking-p)
      "* %?\n:PROPERTIES:\n:CREATED: %U\n:CLOCK-TASK: %(eej/clock-task-id-link)\n:END:\n#+begin_src %^{Language|emacs-lisp|python|bash|c++}\n%i\n#+end_src\n"
    "* %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n#+begin_src %^{Language|emacs-lisp|python|bash|c++}\n%i\n#+end_src\n"))

(defvar eej/capture-clock-link-alist
  '(("j" . "JOURNAL")
    ("r" . "REFERENCES")
    ("b" . "REFERENCES")
    ("s" . "REFERENCES"))
  "Alist of (CAPTURE-KEY . BACKLINK-PROPERTY).
Capture keys listed here get bidirectional linking with the clocked task.")

(defun eej/capture-clock-link--backlink-prop ()
  "Return the backlink property name for the current capture, or nil."
  (cdr (assoc (plist-get org-capture-plist :key)
              eej/capture-clock-link-alist)))

(defun eej/capture-clock-link-ensure-id ()
  "Give the captured entry an org-id when a clock is running.
Runs on `org-capture-prepare-finalize-hook'."
  (when (and (eej/capture-clock-link--backlink-prop)
             (org-clocking-p))
    (org-id-get-create)))

(defun eej/capture-clock-link-add-backlink ()
  "Add a backlink property on the clocked task pointing to the captured entry.
Runs on `org-capture-after-finalize-hook'.  Appends when the
property already exists so multiple entries accumulate."
  (let ((prop (eej/capture-clock-link--backlink-prop)))
    (when (and prop
               (org-clocking-p)
               org-capture-last-stored-marker
               (marker-buffer org-capture-last-stored-marker))
      (let ((entry-id
             (org-with-point-at org-capture-last-stored-marker
               (org-id-get)))
            (timestamp (format-time-string "%Y-%m-%d %H:%M")))
        (when entry-id
          (org-with-point-at org-clock-marker
            (let* ((link (format "[[id:%s][%s]]" entry-id timestamp))
                   (existing (org-entry-get nil prop)))
              (org-set-property
               prop
               (if existing (concat existing " " link) link)))))))))

(add-hook 'org-capture-prepare-finalize-hook #'eej/capture-clock-link-ensure-id)
(add-hook 'org-capture-after-finalize-hook #'eej/capture-clock-link-add-backlink)

;; TODO: consult-org-heading or consult-org-agenda
(use-package org
  ;; It's necessary to place everything in :config otherwise org mode loading is sad
  :init
  (setq org-replace-disputed-keys t)
  :config
  (org-babel-do-load-languages 'org-babel-load-languages '((sql . t) (emacs-lisp . t) (shell . t)))
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
        org-confirm-babel-evaluate nil
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

  ;; Ensure org files exist with proper scaffolding
  (defvar eej/org-file-scaffolds
    '(("projects.org" . "#+TITLE: Projects\n#+STARTUP: overview indent\n\n* Inbox\n")
      ("journal.org"  . "#+TITLE: Journal\n#+FILETAGS: :journal:\n#+STARTUP: overview indent\n#+PROPERTY: CREATED_ALL t\n")
      ("notebook.org" . "#+TITLE: Notebook\n#+FILETAGS: :notebook:\n#+STARTUP: overview indent\n#+PROPERTY: CREATED_ALL t\n#+TAGS: reference bookmark snippet howto\n\n* References\n* Bookmarks\n* How-To\n* Snippets\n"))
    "Alist of (FILENAME . SCAFFOLD) for org files that should exist.")

  (dolist (entry eej/org-file-scaffolds)
    (let ((path (expand-file-name (car entry) org-directory)))
      (unless (file-exists-p path)
        (make-directory (file-name-directory path) t)
        (write-region (cdr entry) nil path)
        (message "Created %s" path))))

  ;; Generic capture templates — site-specific templates are appended
  ;; in local-config.el via `add-to-list'.
  (setq org-capture-templates
        '(("t" "Task" entry (file+headline "projects.org" "Inbox")
           "* TODO %?\n:LOGBOOK:\n:END:\n" :prepend t)
          ("n" "Note on clocked task" entry (clock)
           "* NOTE %U %^{NOTE}" :immediate-finish t)
          ("C" "Child task under clock" entry (clock)
           "* TODO %?\n:LOGBOOK:\n:END:\n" :prepend t)
          ("j" "Journal" entry (file+olp+datetree "journal.org")
           (function eej/capture-template-journal))
          ("r" "Reference" entry (file+headline "notebook.org" "References")
           (function eej/capture-template-reference))
          ("b" "Bookmark" entry (file+headline "notebook.org" "Bookmarks")
           (function eej/capture-template-bookmark))
          ("s" "Snippet" entry (file+headline "notebook.org" "Snippets")
           (function eej/capture-template-snippet))))

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
    (setq jiralib-url (getenv "JIRA_URL")
          request-log-level 'debug
          url-debug t
          jiralib-user-login-name (getenv "EEJ_EMAIL")
          jiralib-atlassian-cloud-token jira-token
          jiralib-token (when jira-token
                          `("Authorization" . ,(format "Basic %s"
                                                       (base64-encode-string
                                                        (concat jiralib-user-login-name ":" jira-token) t)))))))

(use-package org-super-agenda)

(use-package visual-fill-column
  :hook (org-mode . visual-fill-column-mode)
  :custom
  (visual-fill-column-width 150)
  (visual-fill-column-enable-sensible-window-split t)
  :config
  (add-hook 'visual-fill-column-mode-hook #'visual-line-mode))

(provide 'org-custom)
;;; org-custom.el ends here

  ;; The Problem: When you jump from the agenda to projects.org using Enter, the buffer is being visited but the org-mode-hook might not be running completely or font-lock isn't properly initialized. This is a known issue with org-mode when buffers are opened indirectly through the agenda.
  ;; Possible causes:
  ;;  1. org-super-agenda-mode is enabled globally (line 218 in local-config.el) which might interfere with normal org-mode buffer setup
  ;;  2. Font-lock might not be re-enabled when jumping from agenda
  ;;  3. The agenda might be using find-file-noselect or similar functions that don't trigger all hooks properly
  ;; Here's what I recommend:
  ;;  1. First, let's verify the issue - Can you check if font-lock-mode is actually enabled in the unformatted buffer? Run M-x describe-mode or check the modeline when you're in the "unformatted" projects.org buffer.
  ;;  2. Try forcing font-lock refresh - When you see the unformatted buffer, try running M-x font-lock-fontify-buffer to see if that fixes it temporarily.
  ;;  3. Likely fix - Add a hook to ensure font-lock is properly enabled when visiting from agenda:
  ;;  (add-hook 'org-agenda-after-show-hook #'font-lock-fontify-buffer)
  ;; Or more robustly, ensure the org-mode buffer is properly initialized:
  ;;  (defun spectral-org-agenda-after-show-setup ()
  ;;    "Ensure proper org-mode setup after showing from agenda."
  ;;    (when (derived-mode-p 'org-mode)
  ;;      (font-lock-mode 1)
  ;;      (font-lock-fontify-buffer)))
  ;;  (add-hook 'org-agenda-after-show-hook #'spectral-org-agenda-after-show-setup)
  ;; Would you like me to add this fix to your configuration?
