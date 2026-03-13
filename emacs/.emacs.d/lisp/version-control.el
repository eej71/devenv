;;; version-control.el --- Git and project management -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Magit, project.el, and related version-control configuration.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

(use-package magit
  :bind
  ("C-c g" . magit-file-dispatch)

  :hook
  (find-file . eej/is-buffer-read-only)

  :custom
  (magit-diff-refine-hunk 'all))

(use-package project
  :config
  (setq project-switch-commands '((consult-project-extra-find "Find file") (project-find-regexp "Find regexp")
                                  (project-find-dir "Find directory") (project-vc-dir "VC-Dir")
                                  (project-eshell "Eshell"))))

(defun spectral-git-commit-setup ()
  "Modifications to the git commit buffer."
  (setq-local fill-column 120))

(use-package github)

(defun eej/worktree-list ()
  "Return alist of (branch . path) for existing git worktrees."
  (let ((lines (split-string
                (string-trim
                 (shell-command-to-string "git worktree list --porcelain"))
                "\n" t))
        result path)
    (dolist (line lines)
      (cond
       ((string-prefix-p "worktree " line)
        (setq path (substring line 9)))
       ((string-prefix-p "branch " line)
        (push (cons (file-name-nondirectory (substring line 7)) path)
              result))))
    (nreverse result)))

(defun eej/worktree-create (branch)
  "Create a git worktree for BRANCH as a sibling of the project root.
If BRANCH does not exist, create it from the current HEAD."
  (interactive "sBranch name: ")
  (let* ((root (eej/project-root-or-default))
         (parent (file-name-directory (directory-file-name root)))
         (project-name (file-name-nondirectory (directory-file-name root)))
         (wt-dir (expand-file-name (concat project-name "-" branch) parent))
         (branch-exists (zerop (call-process "git" nil nil nil
                                             "rev-parse" "--verify" branch))))
    (when (file-directory-p wt-dir)
      (user-error "Worktree directory already exists: %s" wt-dir))
    (let ((default-directory root))
      (if branch-exists
          (unless (zerop (call-process "git" nil "*git-worktree*" nil
                                       "worktree" "add" wt-dir branch))
            (user-error "git worktree add failed — see *git-worktree* buffer"))
        (unless (zerop (call-process "git" nil "*git-worktree*" nil
                                     "worktree" "add" "-b" branch wt-dir))
          (user-error "git worktree add -b failed — see *git-worktree* buffer"))))
    (find-file wt-dir)
    (message "Worktree created: %s (%s)" wt-dir branch)
    wt-dir))

(defun eej/worktree-create-and-claude (branch)
  "Create a git worktree for BRANCH and launch claude-code-ide in it."
  (interactive "sBranch name: ")
  (let ((wt-dir (eej/worktree-create branch)))
    (let ((default-directory wt-dir))
      (claude-code-ide))))

(defun eej/worktree-switch ()
  "Switch to an existing worktree via completing-read."
  (interactive)
  (let* ((worktrees (eej/worktree-list))
         (choice (completing-read "Worktree: "
                                  (mapcar #'car worktrees) nil t))
         (path (cdr (assoc choice worktrees))))
    (find-file path)))

(defun eej/worktree-remove ()
  "Remove a worktree via completing-read."
  (interactive)
  (let* ((worktrees (eej/worktree-list))
         (choice (completing-read "Remove worktree: "
                                  (mapcar #'car worktrees) nil t))
         (path (cdr (assoc choice worktrees))))
    (when (yes-or-no-p (format "Remove worktree %s at %s? " choice path))
      (let ((default-directory (eej/project-root-or-default)))
        (unless (zerop (call-process "git" nil "*git-worktree*" nil
                                     "worktree" "remove" path))
          (user-error "git worktree remove failed — see *git-worktree* buffer"))
        (message "Removed worktree: %s" path)))))

(define-prefix-command 'eej-worktree-map)
(define-key eej-worktree-map (kbd "c") #'eej/worktree-create)
(define-key eej-worktree-map (kbd "C") #'eej/worktree-create-and-claude)
(define-key eej-worktree-map (kbd "s") #'eej/worktree-switch)
(define-key eej-worktree-map (kbd "r") #'eej/worktree-remove)
(define-key eej-worktree-map (kbd "l") #'eej/worktree-switch)
(global-set-key (kbd "C-c w") 'eej-worktree-map)

(provide 'version-control)
;;; version-control.el ends here
