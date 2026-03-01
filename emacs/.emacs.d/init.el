;;; init.el --- My Emacs configuration -*- lexical-binding: t; -*-
;; -*- mode: emacs-lisp; flycheck-disabled-checkers: (emacs-lisp-checkdoc); -*-
;;
;; Build requirements:
;;   sudo yum install libgccjit{,-devel}.x86_64 libtree-sitter-devel.x86_64
;;   sudo yum install jansson-devel.x86_64 librsvg2-devel.x86_64
;;   PKG_CONFIG_PATH=/home/ejohnson/projects/tree-sitter/
;;   ./configure --with-native-compilation --with-tree-sitter --with-x --with-rsvg --with-modules
;;
;; Local Variables:
;; byte-compile-warnings: (not unresolved free-vars)
;; End:

;;; Code:

;; ── Feature gate ────────────────────────────────────────────────────────
(defun spectral-emacs-config-check (feature)
  "Check Emacs config to see if FEATURE is present."
  (if (string-search feature system-configuration-options)
      t
    (error (concat "Emacs not built with " feature))))
(defconst spectral-emacs-requires-configs
  '("--with-native-compilation" "--with-tree-sitter" "--with-x" "--with-rsvg")
  "These are the minimum features that spectral requires of Emacs.")
(mapc #'spectral-emacs-config-check spectral-emacs-requires-configs)

;; ── Package bootstrap (straight.el + use-package) ──────────────────────
(setq straight-use-package-by-default t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(straight-use-package 'org)

;; ── Custom file ─────────────────────────────────────────────────────────
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))

;; ── Load modular configuration ─────────────────────────────────────────
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'editor-utilities)        ; utility functions used by other modules
(require 'ui-chrome)               ; theme, modeline, window management
(require 'completion-framework)    ; vertico, consult, orderless, marginalia, embark
(require 'programming-modes)       ; treesit, corfu, flymake, formatting
(require 'version-control)         ; magit, project
(require 'power-user-tools)        ; advanced productivity packages (avy, expand-region, etc)
(require 'copilot-chat-custom)     ; copilot-chat persistence & metadata
(require 'ai-tools)                ; copilot, gptel, agent-shell
(require 'org-custom)              ; org mode & org-jira

;; Load custom.el after modules so the theme is available
(when (file-exists-p custom-file)
  (load custom-file))

;; ── General defaults ────────────────────────────────────────────────────
(global-auto-revert-mode t)
(setq fill-column 120
      tab-always-indent 'complete
      completion-cycle-threshold 3)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'compilation-search-path 'safe-local-variable 'string-or-null-p)

(use-package ack :init
  (setq
   ack-and-a-half-arguments "--ignore-dir=release --ignore-dir=debug"))

;; ── Local machine-specific config ───────────────────────────────────────
(require 'local-config "~/.emacs.d/local-config.el")

;;; init.el ends here
