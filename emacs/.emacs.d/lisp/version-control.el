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
  :straight (:type built-in)
  :config
  (setq project-switch-commands '((consult-project-extra-find "Find file") (project-find-regexp "Find regexp")
                                  (project-find-dir "Find directory") (project-vc-dir "VC-Dir")
                                  (project-eshell "Eshell"))))

(defun spectral-git-commit-setup ()
  "Modifications to the git commit buffer."
  (setq-local fill-column 120))

(use-package github)

(provide 'version-control)
;;; version-control.el ends here
