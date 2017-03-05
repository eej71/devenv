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
                                     ("PROJ" :foreground "white" :background "red3" :weight bold))))

(setq org-todo-keywords '(
                          ;; Action sequences where I'm the actor
                          (sequence "TODO" "STARTED" "WAITING" "|" "DONE" "CNCL")
                          (sequence "NOTE") ; Do I want a DONE state for Notes?
                          (sequence "OPS")
                          (sequence "AGENDA" "DONE")))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock)

(setq org-refile-targets '(
                           (org-agenda-files . (:tag . "project"))
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

(defun eej-find-most-nested-started ()
  "Locate the nested most started"
  (save-restriction
    (org-narrow-to-subtree)
    (outline-next-heading)
    (let ((p (point)))
      (if (re-search-forward "STARTED" nil t)
      (progn
        (beginning-of-line)
        (point))
    nil))))

(setq eej-project-list-keywords '("TODO" "DONE" "CNCL" "STARTED" "WAITING"))

(defun eej/is-project-p ()
  "Any task with a todo keyword subtask"
  (let ((has-subtask)
        (subtree-end (save-excursion (org-end-of-subtree t))))
    (save-excursion
      (forward-line 1)
      (while (and (not has-subtask)
                  (< (point) subtree-end)
                  (re-search-forward "^\*+ " subtree-end t))
        (when (member (org-get-todo-state) eej-project-list-keywords)
      (setq has-subtask t))))
    has-subtask))

(defun eej/find-stuck-projects ()
  "
Skip trees that are not stuck projects.  Three criteria have to be met.
  (1) It has to be a TODO item
  (2) It can't have any subprojects
  (3) It can't have its own STARTED task"
  (let* ((number-stars (1+ (org-current-level)))
     (subtree-end (save-excursion (org-end-of-subtree t)))
     ;; See if have a STARTED action at this level - result kept in has-next
     (has-started (save-excursion
                    (forward-line 1)
                    (and (< (point) subtree-end)
                         (re-search-forward (concat "^" (regexp-quote (make-string number-stars ?*)) " \\(STARTED\\)\\|\\(WAITING\\) ")
                                            subtree-end t))))
     (has-todo nil)
     (has-subproject nil))

    ;; See if there are subprojects and todos
    (save-excursion
      (while (< (point) subtree-end)
        (if (re-search-forward (concat "^" (regexp-quote (make-string number-stars ?*)) " TODO ") subtree-end t)
            (progn
              (beginning-of-line)
              (if (and (not has-subproject) (eej/is-project-p))
                  (setq has-subproject (point))
                (setq has-todo t))
          (forward-line 1))
          (goto-char subtree-end))))
    (if (and (not has-subproject) (not has-started) (eej/is-project-p) (not has-todo))
        nil ; a stuck project, has subtasks but no next task
      (or has-subproject subtree-end))))

(defun eej/find-project-tasks ()
  "Find bottom level tasks inside projects."
  (let ((subtree-end
         (save-excursion (progn (forward-line 1) (point)))))
    (if (eej/is-project-p) subtree-end nil)))

(defun eej/skip-projects ()
  "Skip trees that are projects"
  (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (eej/is-project-p) subtree-end nil)))

(defun eej/clock-in-to-next (kw)
  "Switch task from TODO to NEXT when clocking in. Skips remember tasks and tasks with subtasks"
  (if (and (string-equal kw "TODO")
           (not (string-equal (buffer-name) "*Remember*")))
      (let ((subtree-end (save-excursion (org-end-of-subtree t)))
            (has-subtask nil))
        (save-excursion
          (forward-line 1)
          (while (and (not has-subtask)
                      (< (point) subtree-end)
                      (re-search-forward "^\*+ " subtree-end t))
            (when (member (org-get-todo-state) org-not-done-keywords)
              (setq has-subtask t))))
        (when (not has-subtask)
          "STARTED"))))

(setq org-clock-in-switch-to-state (quote eej/clock-in-to-next))

;; These don't handle narrowed regions correctly
(add-hook 'org-create-file-search-functions  '(lambda () (number-to-string (line-number-at-pos))))
(add-hook 'org-execute-file-search-functions '(lambda (search-string) (goto-line (string-to-number search-string))))

;; Needed because indented levels in the clock table report (C-a r)
;; will display \\emsp and I can't figure out how to make it look
;; nice. So this is what it will be. Borrowed from this thread.
;; http://lists.gnu.org/archive/html/emacs-orgmode/2014-08/msg00974.html
(defun org-clocktable-indent-string (level)
  (if (= level 1) ""
    (let ((str " "))
      (dotimes (k (1- level) str)
        (setq str (concat "__" str))))))

(defvar eej/org-headline-cache nil "Stores a cache of the clocktable as computed for the tag")
(defun clocktime-for-tag (headline tag)
  "Filters the clocktime for a headline based on a tag"
  (save-excursion
    (with-current-buffer "projects.org"
      (if (not eej/org-headline-cache)
          (setq eej/org-headline-cache (org-clock-get-table-data nil (append (list ':tags tag) (plist-put params ':formula nil)))))
      (let ((headlines eej/org-headline-cache)
            (clocktime 0))
        (if (or (string= headline "*Total time*") (string= headline "ALL *Total time*"))
            (setq clocktime (nth 1 headlines))
          (dolist (line (nth 2 headlines))
            (if (string-match (nth 1 line) headline) (setq clocktime (nth 3 line)))))
        (org-minutes-to-clocksum-string clocktime)))))

(provide 'org-config)
