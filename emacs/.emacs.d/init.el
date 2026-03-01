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

(defun spectral-org-setup ()
  "Initialize our org mode buffers."
  (turn-on-font-lock)
  (org-indent-mode t)
  (whitespace-mode -1))

;; Load Org from straight before any module can pull in the built-in Org.
(straight-use-package
 '(org :type git :host github :repo "emacs-straight/org-mode"))
(require 'org)
(require 'org-clock)

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
        org-agenda-sorting-strategy  '((agenda habit-down time-up priority-down category-keep)
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
        org-refile-use-outline-path 4
        org-return-follows-link t
        org-reverse-note-order t
        org-startup-indented t
        org-tags-column 120
        org-tags-match-list-sublevels t

(spectral-assert-straight-org)

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

  (add-hook 'org-mode-hook #'spectral-org-setup)
  (add-hook 'org-clock-out-hook #'spectral-recompute-clock-sum)
  (add-hook 'org-mode-hook #'visual-line-mode)
  (add-hook 'org-shiftup-final-hook #'windmove-up)
  (add-hook 'org-shiftleft-final-hook #'windmove-left)
  (add-hook 'org-shiftdown-final-hook #'windmove-down)
  (add-hook 'org-shiftright-final-hook #'windmove-right)

;; Don't grab mouse events in terminal Emacs (keeps Windows Terminal selection working)
;; TODO: This should be put into something more generic for frame creation
(unless (display-graphic-p)
  (xterm-mouse-mode -1))

  :bind
  (("C-c a" . org-agenda)
  ("C-c c" . org-capture)

  :map org-mode-map
  ("C-x <up>" . 'org-metaup)
  ("C-x <down>" . 'org-metadown)
  ("C-x <left>" . 'org-metaleft)
  ("C-x <right>" . 'org-metaright)))

(use-package org-jira
  ;; It's necessary to place everything in :config otherwise org jira is sad
  :config
  (add-hook 'org-clock-out-hook #'eej/post-worklog-to-jira))

(use-package org-super-agenda)

(defun eej-indent-style ()
  "Override the built in indentation with my own choices."
  `(;; custom rules
    ((n-p-gp nil nil "namespace_definition") grand-parent 0)
    ,@(alist-get 'gnu (c-ts-mode--indent-styles 'cpp))))

(use-package treesit
  :straight nil
  :config
  (add-to-list 'treesit-language-source-alist '(bash "https://github.com/tree-sitter/tree-sitter-bash"))
  (add-to-list 'treesit-language-source-alist '(c "https://github.com/tree-sitter/tree-sitter-c.git"))
  (add-to-list 'treesit-language-source-alist '(cmake "https://github.com/uyha/tree-sitter-cmake"))
  (add-to-list 'treesit-language-source-alist '(cpp "https://github.com/tree-sitter/tree-sitter-cpp.git"))
  (add-to-list 'treesit-language-source-alist '(css "https://github.com/tree-sitter/tree-sitter-css"))
  (add-to-list 'treesit-language-source-alist '(elisp "https://github.com/Wilfred/tree-sitter-elisp.git"))
  (add-to-list 'treesit-language-source-alist '(go "https://github.com/tree-sitter/tree-sitter-go"))
  (add-to-list 'treesit-language-source-alist '(html "https://github.com/tree-sitter/tree-sitter-html"))
  (add-to-list 'treesit-language-source-alist '(javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src"))
  (add-to-list 'treesit-language-source-alist '(json "https://github.com/tree-sitter/tree-sitter-json"))
  (add-to-list 'treesit-language-source-alist '(make "https://github.com/alemuller/tree-sitter-make"))
  (add-to-list 'treesit-language-source-alist '(markdown "https://github.com/ikatyang/tree-sitter-markdown"))
  (add-to-list 'treesit-language-source-alist '(python "https://github.com/tree-sitter/tree-sitter-python"))
  (add-to-list 'treesit-language-source-alist '(toml "https://github.com/tree-sitter/tree-sitter-toml"))
  (add-to-list 'treesit-language-source-alist '(tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src"))
  (add-to-list 'treesit-language-source-alist '(typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
  (add-to-list 'treesit-language-source-alist '(yaml "https://github.com/ikatyang/tree-sitter-yaml"))
  ;; TODO: Bring this back once we are running emacs as a daemon again
  ;;(mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))
  :custom
  (major-mode-remap-alist '((c++-mode . c++-ts-mode) (c-mode . c++-ts-mode) (c-or-c++-mode . c++-ts-mode)))
  (c-ts-mode-indent-style #'eej-indent-style)
  (treesit-font-lock-level 4))

(use-package spectral-theme
  :straight nil
  ;;:load-path "~/.emacs.d/"

  ;; TODO: Is init the right time and place? - or should it be config?
  :init
  (add-to-list 'custom-theme-load-path "~/.emacs.d/")
  (load-file "~/.emacs.d/modeline.el")
  (load-theme 'spectral t))

(straight-use-package '(vertico :files (:defaults "extensions/*")
                         :includes (vertico-buffer
                                    vertico-directory
                                    vertico-flat
                                    vertico-indexed
                                    vertico-mouse
                                    vertico-quick
                                    vertico-repeat
                                    vertico-reverse)))

(use-package vertico
  :config
  (vertico-mode t)
  (vertico-indexed-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  (vertico-count 15)
  (vertico-indexed-start 1))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :ensure nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package savehist
  :straight nil
  :init
  (savehist-mode))

(use-package windmove
  :config
  (windmove-mode)
  (windmove-default-keybindings)
  :custom
  (windmove-wrap-around t))

(defun eej/is-buffer-read-only ()
  "Set the buffer to read only if its a file not managed by git."
  (if (and buffer-file-name
           (not (project-current nil (file-truename default-directory))))
      (read-only-mode t)))

(use-package magit
  :bind
  ("C-c g" . magit-file-dispatch)

  :hook
  (find-file . eej/is-buffer-read-only)

  :custom
  (magit-diff-refine-hunk 'all))

(use-package project
  ;; TODO: Describe-key seems broken for this - is that describe-key being broken or me being broken?
  ;;:bind-keymap ("f" . project-prefix-map) ;; Already mapped as C-x p
  :config
  (setq project-switch-commands '((consult-project-extra-find "Find file") (project-find-regexp "Find regexp")
                                  (project-find-dir "Find directory") (project-vc-dir "VC-Dir")
                                  (project-eshell "Eshell"))))

(defun spectral-git-commit-setup ()
  "Modifications to the git commit buffer."
  (setq-local fill-column 120))

;; Normally I would add this with the :hook mechanism, but it didn't work with git-commit?
;;(add-hook 'git-commit-setup-hook #'spectral-git-commit-setup)

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  :custom
  ;; We are limited to a total of 9 faces - so we just skip every other color group
  (rainbow-x-colors nil) ;; Dislike the names of colors being colored
  (rainbow-delimiters-max-face-count 7))

(use-package ace-window
  :bind (("M-o" . ace-window)
         ("C-x o" . ace-window))   ;; replace default other-window
  :config
  (ace-window-display-mode 1)
  (setq aw-keys '(?a ?s ?d ?f ?j ?k ?l)
        aw-dispatch-always t
        aw-background nil
        aw-split-style 'fair)
  )

(use-package smartparens)

(use-package github)

(use-package orderless
  :custom
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)
  (completion-styles '(substring flex orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; TODO: More to setup here
(use-package consult
  :init
  (define-prefix-command 'eej-consult)
  (global-set-key (kbd "C-c s") 'eej-consult)

  :bind
  ("C-x b" . consult-buffer)
  ;; TODO: consult-history - what is it?
  ;; TODO: consult-man seems broken
  ("C-x r b" . consult-bookmark)
  ("M-g g" . consult-goto-line)

  ("C-c s f" . consult-find)
  ("C-c s g" . consult-grep)
  ("C-c s l" . consult-line)
  ("C-c s L" . consult-line-multi)
  ("C-c s k" . consult-keep-lines)
  ("C-c s r" . consult-ripgrep)
  ("C-c s u" . consult-focus-lines)

  ;; TODO: Could probably rip apart the register kepmap perfix a bit more
  ("C-x r x" . consult-register-store)
  ("C-x r s" . consult-register-store)
  ("C-x r j" . consult-register-load)

  :config
  (setq consult-narrow-key "<")
  (setq consult-ripgrep-args "rg --null --color=never --max-columns=1000 --path-separator /   --smart-case --no-heading --with-filename --line-number --no-search-zip")

  (advice-add #'project-find-regexp :override #'consult-ripgrep)

  ;; Improves the usability of the register window...
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  )

(use-package consult-project-extra
  :straight t
  :bind
  ;; TODO: The problem with this setup is that this wrecks project-switch-buffer keymap - no way to pick a file
  ;; 1) Try declaring this in the bind-keymap portion of the project loading
  ;; 2) Try a bind-keymap thing here instead of just stuffing this into that key sequence
  (("C-x p f" . consult-project-extra-find)
   ("C-x p o" . consult-project-extra-find-other-window)))

;; TODO: Add a hook so when something is staged in an engine repo - we call clang-format on that region
(use-package clang-format)

(use-package recentf
  :config
  (recentf-mode t)
  (run-at-time nil 600 'recentf-save-list)
  :custom
  (recentf-max-menu-items 50
   recentf-max-saved-items 50))

;; TODO: Is ack still in use?
(use-package ack :init
  (setq
   ack-and-a-half-arguments "--ignore-dir=release --ignore-dir=debug"))

;; TODO: Purge uniquify if its not needed
;;(straight-use-package 'uniquify-files)
;;(use-package uniquify-files)
;;:custom (uniquify-buffer-name-style '(post-forward-angle-brackets nil (uniquify))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(backup-directory-alist (list '(".*" . "~/tmp/")))
 '(compilation-mode-line-errors
   '(" ["
     (:propertize (:eval (int-to-string compilation-num-errors-found)) face compilation-error help-echo
                  "Number of errors so far")
     "]") t)
 '(compilation-skip-threshold 1)
 '(completion-ignore-case t t)
 '(custom-enabled-themes '(spectral))
 '(custom-safe-themes
   '("841f05044422544925a592e810c73b6e44d41fb9f40d86960dc79a3fd2ce4803"
     "fbcba8deb199e323f26cf4244ceadfc54c5914a473490456707c109701e14909"
     "9932992fd74b289a1ceda66b9a34c882e11a3189e25cc7398710f03ab8f0144f" default))
 '(custom-theme-directory "~/devenv/elisp/")
 '(dired-isearch-filenames t)
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width 3)
 '(exec-path-from-shell-check-startup-files nil)
 '(fci-rule-color "#383838")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(git-commit-summary-max-length 120)
 '(global-display-line-numbers-mode nil)
 '(gtags-suggested-key-mapping t)
 '(inhibit-startup-screen t)
 '(linum-format "%4d ")
 '(mode-line-format
   '(" " mode-line-position mode-line-modified mode-line-frame-identification mode-line-buffer-identification
     (vc-mode vc-mode) mode-line-modes mode-line-misc-info mode-line-end-spaces))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(redisplay-dont-pause t t)
 '(request-curl-options '("-k"))
 '(ring-bell-function nil)
 '(safe-local-variable-values '((flycheck-disabled-checkers emacs-lisp-checkdoc)))
 '(show-paren-style 'parenthesis)
 '(show-paren-when-point-in-periphery t)
 '(show-paren-when-point-inside-paren t)
 '(tramp-default-method "ssh")
 '(transient-mark-mode 1)
 '(undo-tree-history-directory-alist '((".*" . "~/tmp/")))
 '(user-full-name "Eric Johnson")
 '(user-mail-address (getenv "EEJ_EMAIL"))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   '((20 . "#BC8383") (40 . "#CC9393") (60 . "#DFAF8F") (80 . "#D0BF8F") (100 . "#E0CF9F") (120 . "#F0DFAF")
     (140 . "#5F7F5F") (160 . "#7F9F7F") (180 . "#8FB28F") (200 . "#9FC59F") (220 . "#AFD8AF") (240 . "#BFEBBF")
     (260 . "#93E0E3") (280 . "#6CA0A3") (300 . "#7CB8BB") (320 . "#8CD0D3") (340 . "#94BFF3") (360 . "#DC8CC3")))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(vc-follow-symlinks nil)
 '(visible-bell nil)
 '(warning-suppress-log-types '((corfu-doc)))
 '(warning-suppress-types '((native-compiler)))
 '(whitespace-line-column 220)
 '(whitespace-style '(face tabs lines-char indentation::space trailing)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;
;; Eglot is just too much trouble. Can't make it parse compiler_commands.json and nothing works.
;; Other packages to bring in - eldoc, flymake, xref and imenu
;;(use-package eglot
;;  :custom
;;  (eglot-inlay-hints-mode 0)
;;  :hook
;;  ;;(c++-ts-mode . eglot-ensure)
;;  )

;; debug this function with debug to see why M-t is not doing this corfu-popupinfo-toggle
(use-package corfu
  :straight
  (corfu :files (:defaults "extensions/*")
         :includes (corfu-info corfu-history corfu-popupinfo corfu-indexed))

  :init
  (corfu-popupinfo-mode)
  (corfu-indexed-mode)
  (corfu-history-mode)
  (global-corfu-mode)

  :custom
  (corfu-min-width 30)
  ;;(corfu-popupinfo-delay 0)
  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  (corfu-scroll-margin 5)        ;; Use scroll margin
  (corfu-count 20))

(straight-use-package
 '(corfu-terminal
   :type git
   :repo "https://codeberg.org/akib/emacs-corfu-terminal.git"))

(unless (display-graphic-p)
  (corfu-terminal-mode +1))

(straight-use-package
 '(corfu-doc-terminal
   :type git
   :repo "https://codeberg.org/akib/emacs-corfu-doc-terminal.git"))
(unless (display-graphic-p)
  ;; This is here because corfu-popupinfo isn't really working for the terminal
  (corfu-doc-mode +1)
  (corfu-doc-terminal-mode +1))

(use-package flymake
  :init
  ;; Create a useful prefix command to navigate flymake commands
  (define-prefix-command 'eej-flymake-map)
  (global-set-key (kbd "C-c f") 'eej-flymake-map)
  (flymake-mode +1)
  (define-key eej-flymake-map (kbd "c") 'consult-flymake)
  (define-key eej-flymake-map (kbd "n") 'flymake-goto-next-error)
  (define-key eej-flymake-map (kbd "p") 'flymake-goto-prev-error)
  (define-key eej-flymake-map (kbd "r") 'clang-format-region)
  (define-key eej-flymake-map (kbd "b") 'clang-format-buffer))

(defun eej/prog-mode-setup ()
  "Perform all the required setup for a prog mode."
  (setq-default indent-tabs-mode nil)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M [])
  (display-line-numbers-mode t)
  (whitespace-mode t)
  (setq fill-column 120)
  (setq-default nxml-slash-auto-complete-flag t)
  (flymake-mode +1)
  (electric-pair-local-mode t))

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)
  (setq fill-column 120)
  (put 'downcase-region 'disabled nil)
  (put 'upcase-region 'disabled nil)
  (put 'compilation-search-path 'safe-local-variable 'string-or-null-p)
  :hook
  (prog-mode . eej/prog-mode-setup)
  (nxml-mode . eej/prog-mode-setup)
  (c-initialization .  (lambda () "" (define-key c-mode-base-map "\C-m" 'c-context-line-break)))
  :config
  (tool-bar-mode -1)
  (global-auto-revert-mode t)
  (menu-bar-mode -1)
  (scroll-bar-mode -1)
  ;;(global-hl-line-mode -1)

  ;; Emacs 28: Hide commands in M-x which do not apply to the current mode.
  ;; Corfu commands are hidden, since they are not supposed to be used via M-x.
  ;; (setq read-extended-command-predicate
  ;;       #'command-completion-default-include-p)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (setq tab-always-indent 'complete))

;; TODO: We can remove this once windows terminal program fixes their C-spc bug
(global-set-key [f7] 'set-mark-command)
(global-set-key (kbd "C-x z") 'ff-get-other-file)

(use-package marginalia
  :config
  (marginalia-mode t))

(use-package which-key
  :config
  (which-key-mode t)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-side-window-location 'bottom))


;; TODO: Copied from https://github.com/oantolin/embark
(use-package embark
  :ensure t

  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("M-." . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc.  You may adjust the Eldoc
  ;; strategy, if you want to see the documentation from multiple providers.
  (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package yaml-mode)

;; Colorizes rgb names
(defun spectral-enable-colorized-words ()
  "Colorizes strings with the right color."
  (rainbow-mode t))
(use-package rainbow-mode
  :config
  (add-hook 'emacs-lisp-mode-hook #'spectral-enable-colorized-words))

(use-package vterm
  :straight t
  :config
  (setq vterm-shell "bash")) ; Optional: set your shell

(use-package gptel
  :straight (:host github :repo "karthink/gptel")
  :config
  (setq gptel-model 'claude-sonnet-4-5-20250929)
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :key (getenv "CLAUDE_API_KEY")
          :models '(claude-sonnet-4-5-20250929))))

(straight-use-package
 '(shell-maker :type git
               :host github
               :repo "xenodium/shell-maker"))

(straight-use-package
 '(acp :type git
       :host github
       :repo "xenodium/acp.el"))

;; Ensure Emacs has the same PATH you'd use in a terminal
(add-to-list 'exec-path "/usr/local/bin")
(add-to-list 'exec-path "/home/WORKNAME/.nvm/versions/node/v20.20.0/bin/codex-acp")
(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))

;; Use login-based auth (no API key)
;;(setq agent-shell-openai-authentication (agent-shell-openai-make-authentication :login t))

;; IMPORTANT: inherit env so Codex sees HOME, PATH, cert vars, proxies, etc.
;;(setq agent-shell-openai-codex-environment (agent-shell-make-environment-variables :inherit-env t))

(use-package agent-shell
  :straight (:host github :repo "xenodium/agent-shell"))


(use-package buttercup :straight t)

(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
       :branch "main"
       :rev :newest)

  :bind (:map copilot-mode-map
         ("M-/" . copilot-complete)
         :map copilot-completion-map
         ("TAB" . eej-copilot-tab-or-indent)
         ("<tab>" . eej-copilot-tab-or-indent)
         ("C-g" . copilot-clear-overlay)
         ("M-n" . copilot-next-completion)
         ("M-p" . copilot-previous-completion)
         ("M-f" . copilot-accept-completion-by-word)
         ("M-e" . copilot-accept-completion-by-line)
         )

  :hook (prog-mode . copilot-mode)

  :config
  ;; Map major-mode (symbol) -> Copilot language id (string)
  (add-to-list 'copilot-major-mode-alist '(c++-ts-mode . "cpp"))
  (add-to-list 'copilot-major-mode-alist '(c-ts-mode   . "c"))
  (setq copilot-model "claude-opus-4.6")
  (setq copilot-indent-offset-warning-disable t))

(use-package copilot-chat
  :straight (:host github :repo "chep/copilot-chat.el" :files ("*.el"))
  :after (request org markdown-mode)
  :config
  (setq copilot-chat-default-model "claude-opus-4.6")
  )

(use-package visual-fill-column
  :ensure t
  :hook (org-mode . visual-fill-column-mode)
  :custom
  (visual-fill-column-width 150)
  (visual-fill-column-enable-sensible-window-split t)
  :config
  (add-hook 'visual-fill-column-mode-hook #'visual-line-mode))

;; Not sure what these are for or if we need them
;; `vertico-previous'.
;;(keymap-set vertico-map "M-q" #'vertico-quick-insert)
;;(keymap-set vertico-map "C-q" #'vertico-quick-exit)

;;; CODE:
(defun eej/find-stuck-projects ()
  "A project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO."
  (let ((at-least-one-action (save-excursion (org-agenda-skip-subtree-if 'todo '("STARTED" "WAITING" "NEXT"))))
        (at-least-one-done (save-excursion (org-agenda-skip-subtree-if 'todo 'done)))
        (at-least-one-scheduled (save-excursion (-some #'identity (remove nil (org-map-entries #'eej/is-todo-scheduled t 'tree))))))
    (if (and at-least-one-done (not at-least-one-action) (not at-least-one-scheduled))
        nil
      (or (outline-next-heading) (org-end-of-subtree t)))))

(defun eej/is-todo-scheduled ()
  "Is this an incomplete todo with a scheduled date."
  (let* ((element (org-element-at-point))
         (todo-type (org-element-property :todo-type element))
         (scheduled (org-element-property :scheduled element)))
    (if (and (eq todo-type 'todo) scheduled)
        (point)
      nil)))

(defun eej/find-nested-started ()
  "Has >1 DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO."
  (if (not (org-goto-first-child))
      nil
    (let ((end (save-excursion (org-end-of-subtree t))))
      (if (re-search-forward "STARTED" end t)
          (progn (beginning-of-line) (point))
        (or
         (org-agenda-skip-subtree-if 'todo '("WAITING"))
         ;; If org-agenda-skip-subtree-if allowed for this...
         ;; (org-agenda-skip-subtree-if 'scheduled 'todo '("DONE"))
         (-some #'identity (remove nil (org-map-entries #'eej/is-todo-scheduled t 'tree)))
         )))))

;; Needed because indented levels in the clock table report (C-a r)
;; will display \\emsp and I can't figure out how to make it look
;; nice. So this is what it will be. Borrowed from this thread.
;; http://lists.gnu.org/archive/html/emacs-orgmode/2014-08/msg00974.html
(defun org-clocktable-indent-string (level)
  "An attempt to improve the formatting of the clocktable for a given LEVEL."
  (if (= level 1) ""
    (let ((str " "))
      (dotimes (k (1- level) str)
        (setq str (concat "__" str))))))

(defun eej/post-worklog-to-jira ()
  "Post up time to jira."
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

(defun spectral-recompute-clock-sum ()
  "Recomputes the clock sum time for the projects buffer."
  (org-align-all-tags)
  (save-window-excursion
    ;; Is there a better way to find this buffer? Seems... clumsy
    (switch-to-buffer "projects.org")
    (goto-char 1)
    (org-clock-sum (org-read-date nil nil "-21d") (org-read-date nil nil "now"))
    (message "Recomputed clocks for projects.org")))

(put 'narrow-to-region 'disabled nil)

;; TODO: Is there a way to get this into use-package?
;;(load-file "modeline.el")
(require 'local-config "~/.emacs.d/local-config.el")
;;; I'm very disappointed with codex integration - so this will likely be purged
(defun eej/start-codex ()
  "Open Codex CLI in ~/fubar (empty dir)."
  (interactive)
  (require 'vterm)
  (let* ((root (expand-file-name "~/fubar"))
         (buf (get-buffer-create "*codex*")))
    (with-current-buffer buf
      (setq default-directory root)
      (unless (derived-mode-p 'vterm-mode)
        (vterm-mode))
      (vterm-send-string (concat "cd " (shell-quote-argument root) "\n")))
    (pop-to-buffer buf)
    (vterm-send-string "codex\n")))

;;; 
(defun eej/copilot-chat--get-property (prop)
  "Extract a #+PROPERTY: PROP value from the current buffer."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward
           (concat "^#\\+PROPERTY:\\s-+" (regexp-quote prop) "\\s-+\\(.+\\)$")
           nil t)
      (string-trim (match-string 1)))))

(defun eej/copilot-chat--get-date ()
  "Extract the #+DATE: value from the current buffer.
Returns the inner timestamp string, e.g. \"2026-02-27 Fri 16:34\"."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward
           "^#\\+DATE:\\s-+\\[\\([^]]+\\)\\]" nil t)
      (string-trim (match-string 1)))))

(defun eej/copilot-chat--compute-filename ()
  "Compute a unique filename for the current Copilot chat buffer.
Uses SESSION_DIR and DATE properties to build the name."
  (let* ((session-dir (eej/copilot-chat--get-property "SESSION_DIR"))
         (date-str    (eej/copilot-chat--get-date))
         (dir         "~/org/chats/"))
    (when (and session-dir date-str)
      ;; Convert session dir: /home/WORKNAME/ejohnson/fubar/ -> _home_WORKNAME_ejohnson_fubar_
      (let* ((dir-part (replace-regexp-in-string "/" "_" session-dir))
             ;; Remove leading/trailing underscores for cleanliness
             (dir-part (replace-regexp-in-string "\\`_+" "" dir-part))
             (dir-part (replace-regexp-in-string "_+\\'" "" dir-part))
             ;; Parse date: "2026-02-27 Fri 16:34" -> "2026_02_27_16_34"
             (date-part (when (string-match
                               "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)\\s-+[A-Za-z]+\\s-+\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)"
                               date-str)
                          (concat (match-string 1 date-str) "_"
                                  (match-string 2 date-str) "_"
                                  (match-string 3 date-str) "_"
                                  (match-string 4 date-str) "_"
                                  (match-string 5 date-str)))))
        (when (and dir-part date-part)
          (unless (file-directory-p dir)
            (make-directory dir t))
          (concat dir date-part "__" dir-part ".org"))))))

(defun eej/copilot-chat-save-buffer ()
  "Save the current buffer if it is a Copilot chat buffer."
  (when (string-match-p "\\`\\*Copilot" (buffer-name))
    (let ((filename (eej/copilot-chat--compute-filename)))
      (when filename
        (write-region (point-min) (point-max) filename nil 'quiet)
        ))))

(defun eej/copilot-chat-auto-save-all ()
  "Auto-save all Copilot chat buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (eej/copilot-chat-save-buffer))))

;; --- Hook: save on buffer kill ---
(defun eej/copilot-chat-kill-hook ()
  "Save Copilot chat buffer before it is killed."
  (eej/copilot-chat-save-buffer))

(add-hook 'kill-buffer-hook #'eej/copilot-chat-kill-hook)

;; --- Timer: save every 10 minutes ---
(defvar eej/copilot-chat-save-timer nil
  "Timer for periodic Copilot chat auto-save.")

(when (timerp eej/copilot-chat-save-timer)
  (cancel-timer eej/copilot-chat-save-timer))

(setq eej/copilot-chat-save-timer
      (run-with-timer 600 600 #'eej/copilot-chat-auto-save-all))

(require 'org-id)
(setq org-id-method 'ts)

;; 1. Session metadata — advise buffer creation
(defun eej/copilot-chat-insert-session-metadata (buffer)
  "Insert session metadata at the top of BUFFER if freshly created."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (and (derived-mode-p 'org-mode)
                 (save-excursion
                   (goto-char (point-min))
                   (not (looking-at-p "#\\+TITLE:"))))
        (save-excursion
          (goto-char (point-min))
          (let* ((dir (or default-directory "unknown"))
                 (branch (string-trim
                          (shell-command-to-string
                           (format "git -C %s rev-parse --abbrev-ref HEAD 2>/dev/null"
                                   (shell-quote-argument dir)))))
                 (timestamp (format-time-string "[%Y-%m-%d %a %H:%M]")))
            (insert (format "#+TITLE: Copilot Chat Session\n"))
            (insert (format "#+DATE: %s\n" timestamp))
            (insert (format "#+PROPERTY: SESSION_DIR %s\n" dir))
            (insert (format "#+PROPERTY: GIT_BRANCH %s\n"
                            (if (string-empty-p branch) "N/A" branch)))
            (insert "\n")))))))

(advice-add 'copilot-chat--org-get-buffer :filter-return
            (lambda (buffer)
              (eej/copilot-chat-insert-session-metadata buffer)
              buffer))

;; 2. Per-heading IDs — advise format-data
(defun eej/copilot-chat-add-heading-id (orig-fn instance content type)
  "Advise `copilot-chat--org-format-data' to inject :ID: property drawers."
  (let ((data (funcall orig-fn instance content type)))
    (cond
     ;; User prompt heading
     ((eq type 'prompt)
      (let ((id (org-id-new)))
        (replace-regexp-in-string
         (regexp-quote (format-time-string "*[%T]* You\n"))
         (format-time-string (concat "*[%T]* You\n"
                                     ":PROPERTIES:\n"
                                     ":ID: " id "\n"
                                     ":END:\n"))
         data t t)))
     ;; First word of answer (heading is generated)
     ((copilot-chat-first-word-answer instance)
      ;; first-word-answer was JUST set to nil by orig-fn,
      ;; but the heading was generated in this call
      (when (string-match (concat ":" copilot-chat--org-answer-tag ":\n") data)
        (let ((id (org-id-new)))
          (replace-regexp-in-string
           (concat ":" copilot-chat--org-answer-tag ":\n")
           (format ":%s:\n:PROPERTIES:\n:ID: %s\n:END:\n"
                   copilot-chat--org-answer-tag id)
           data t t))))
     (t data))))

(advice-add 'copilot-chat--org-format-data :around
            #'eej/copilot-chat-add-heading-id)

(defun eej-copilot-chat-faces ()
  "Make user/AI headings visually distinct in copilot-chat."
  (when (string-match-p "Copilot Chat" (buffer-name))
    (face-remap-add-relative 'org-level-1
                             '(:inverse-video t :weight bold))
    (face-remap-add-relative 'org-level-2
                             '(:weight semi-bold :foreground "gray70"))))

(add-hook 'org-mode-hook #'eej-copilot-chat-faces)

(defun eej-resize-window-hydra ()
  "Interactively resize window with arrow keys. Press q to quit."
  (interactive)
  (let ((done nil))
    (while (not done)
      (let ((key (read-key
                  (format "Resize: [←] narrower [→] wider [↑] taller [↓] shorter [q]uit"))))
        (cond
         ((eq key 'left)  (shrink-window-horizontally 3))
         ((eq key 'right) (enlarge-window-horizontally 3))
         ((eq key 'down)    (enlarge-window 2))
         ((eq key 'up)  (shrink-window 2))
         (t (setq done t)))))))

(global-set-key (kbd "C-c h") 'eej-resize-window-hydra)

(defun eej-copilot-tab-or-indent ()
  "Accept copilot completion if visible, otherwise indent."
  (interactive)
  (if (copilot--overlay-visible)
      (copilot-accept-completion)
    (indent-for-tab-command)))
