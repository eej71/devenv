;;
;; System configurations that are required
;; "--with-native-compilation --with-json --with-tree-sitter --with-x --with-rsvg"
;; System built requires lib
;;
;; sudo yum install libgccjit.x86_64
;; sudo yum install libgccjit-devel.x86_64
;; sudo yum install libtree-sitter-devel.x86_64
;; sudo yum install -y jansson-devel.x86_64
;; sudo yum install -y librsvg2-devel.x86_64

;; Make sure that this emacs has the required features
(mapcar (lambda (x) (if (string-search x system-configuration-options)
                        t
                      (error (concat "Emacs not built with " x))))
        '("--with-native-compilation" "--with-json" "--with-tree-sitter" "--with-x" "--with-rsvg"))

;; TODO: which vertico modes to enable
;; TODO: Add hooks to c-ts-base-mode-hook - probably should be prog-mode

;; TODO: General tasks.
;; 2) Understand indentation rules, so you can improve them and match the engine and strike style
;; 3) Bring over the rest of your modern org mode defuns
;; 4) Make whitespace mode more useful
;; 6) consult-compile-error
;; 7) consult-xref setup
;; 8) make another swipe at smartparens
;; 9) Embark prompt sure is aggressive
;; 12) find-file-hook - should toggle read-only for trampd files
;; 15) ssh to tower.local and other places seems a bit broken
;; 16) Silence this error from flymake - Warning [flymake modeline.el]: Disabling backend flymake-proc-legacy-flymake because (error Can’t find a suitable init function)
;; 17) Correctly bring in modeline via use-package as a loader
;; 18) look at nlinum as a replacement for display-line-number-mode

;; Prevent package.el loading packages prior to their init-file loading
(setq package-enable-at-startup nil)
(setq straight-use-package-by-default t)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))

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
;; TODO: consult-org-heading or consult-org-agenda
(use-package org
  ;; It's necessary to place everything in :config otherwise org mode loading is sad
  :config
  (setq org-adapt-identation t
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
        org-default-notes-file '(concat org-directory "/notes.org")
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
        org-time-clocksum-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t)
        org-refile-targets '((org-agenda-files . (:todo . "STARTED"))
                             (org-agenda-files . (:todo . "NEXT"))
                             (org-agenda-files . (:tag . "refile"))
                             (org-agenda-files . (:todo . "TODO")))

        org-checkbox-hierarchical-statistics nil)
  (org-clock-persistence-insinuate)

  (add-hook 'org-mode-hook #'turn-on-font-lock)
  (add-hook 'org-mode-hook (lambda () "" (org-indent-mode t)))
  (add-hook 'org-mode-hook #'eej-org-mode)
  (add-hook 'org-mode-hook (lambda () "" (whitespace-mode -1)))
  (add-hook 'org-clock-out-hook (lambda () "" (org-align-all-tags)))
  (add-hook 'org-clock-out-hook #'eej/recompute-clock-sum)

  (add-hook 'org-shiftup-final-hook #'windmove-up)
  (add-hook 'org-shiftleft-final-hook #'windmove-left)
  (add-hook 'org-shiftdown-final-hook #'windmove-down)
  (add-hook 'org-shiftright-final-hook #'windmove-right)

  ;; TODO: What are these even for ?
  ;; These don't handle narrowed regions correctly - not sure why these are still here
  ;; Not available? Maybe this should be handled in org-super-agenda
  ;;(org-defkey org-agenda-keymap "r" 'org-agenda-refile)
  (add-hook 'org-create-file-search-functions  (lambda () (number-to-string (line-number-at-pos))))
  (add-hook 'org-execute-file-search-functions (lambda (search-string) (goto-line (string-to-number search-string))))

  :bind
  (("C-c a" . org-agenda)
  ("C-c c" . org-capture)

  :map org-mode-map
  ("C-x <up>" . 'org-metaup)
  ("C-x <down>" . 'org-metadown)
  ("C-x <left>" . 'org-metaleft)
  ("C-x <right>" . 'org-metaright)))

(straight-use-package 'org-jira)
(use-package org-jira
  ;; It's necessary to place everything in :config otherwise org jira is sad
  :config
  (add-hook 'org-clock-out-hook #'eej/post-worklog-to-jira))

(straight-use-package 'org-super-agenda)
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
  (major-mode-remap-alist '((c++-mode . c++-ts-mode) (c-mode . c-ts-mode) (c-or-c++-mode . c-or-c++-ts-mode)))
  (c-ts-mode-indent-style #'eej-indent-style)
  ;; Setting this to 3 or 4 triggers an error from treesit parser - may fix itself with futures sha1s
  (treesit-font-lock-level 2))

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
  (vertico-cycle t)
  (vertico-count 15)
  (vertico-indexed-start 1))

(use-package savehist
  :straight nil
  :init
  (savehist-mode))

(straight-use-package 'windmove)
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

(straight-use-package 'magit)
(use-package magit
  :bind
  ("C-c g" . magit-file-dispatch)
  :hook
  (find-file . eej/is-buffer-read-only)

  :custom
  (magit-diff-refine-hunk 'all))

(straight-use-package 'project)
(use-package project
  ;; TODO: Describe-key seems broken for this - is that describe-key being broken or me being broken?
  ;;:bind-keymap ("f" . project-prefix-map) ;; Already mapped as C-x p
  :config
  (setq project-switch-commands '((consult-project-extra-find "Find file") (project-find-regexp "Find regexp")
                                  (project-find-dir "Find directory") (project-vc-dir "VC-Dir")
                                  (project-eshell "Eshell"))))

(use-package git-commit
  :hook
  (git-commit-mode . (lambda () "" (whitespace-mode -1))))

(straight-use-package 'rainbow-delimiters)
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  :custom
  ;; We are limited to a total of 9 faces - so we just skip every other color group
  (rainbow-x-colors nil) ;; Dislike the names of colors being colored
  (rainbow-delimiters-max-face-count 7))

(straight-use-package 'ace-window)
(use-package ace-window)

(straight-use-package 'smartparens)
(use-package smartparens)

(straight-use-package 'highlight-parentheses)
(use-package highlight-parentheses
  :custom
  (highlight-parentheses-attributes '((:underline t)))
  (highlight-parentheses-colors nil))

(straight-use-package 'github)
(use-package github)

(straight-use-package 'orderless)
(use-package orderless
  :custom
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)
  (completion-styles '(substring flex orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(straight-use-package 'consult)
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
(straight-use-package 'clang-format)
(use-package clang-format)

(straight-use-package 'recentf)
(use-package recentf
  :config
  (recentf-mode t)
  (run-at-time nil 600 'recentf-save-list)
  :custom
  (recentf-max-menu-items 50
   recentf-max-saved-items 50))

;; TODO: Is ack still in use?
(straight-use-package 'ack)
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
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3"
    "#DCDCCC"])
 '(backup-directory-alist (list '(".*" . "~/tmp/")))
 '(beacon-color "#cc6666")
 '(compilation-mode-line-errors
   '(" ["
     (:propertize (:eval (int-to-string compilation-num-errors-found))
                  face compilation-error help-echo
                  "Number of errors so far")
     "]") t)
 '(compilation-skip-threshold 1)
 '(completion-ignore-case t t)
 '(custom-enabled-themes '(spectral))
 '(custom-safe-themes
   '("841f05044422544925a592e810c73b6e44d41fb9f40d86960dc79a3fd2ce4803"
     "fbcba8deb199e323f26cf4244ceadfc54c5914a473490456707c109701e14909"
     "9932992fd74b289a1ceda66b9a34c882e11a3189e25cc7398710f03ab8f0144f"
     default))
 '(custom-theme-directory "~/devenv/elisp/")
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width 3)
 '(exec-path-from-shell-check-startup-files nil)
 '(fci-rule-color "#383838")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(git-commit-summary-max-length 80)
 '(global-display-line-numbers-mode nil)
 '(gtags-suggested-key-mapping t)
 '(inhibit-startup-screen t)
 '(linum-format "%4d ")
 '(mode-line-format
   '(" " mode-line-position mode-line-modified
     mode-line-frame-identification mode-line-buffer-identification
     (vc-mode vc-mode) mode-line-modes mode-line-misc-info
     mode-line-end-spaces))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(project-vc-ignores
   '("Testing/TestModels/TMS74GridTests/refdata/s74output_correct/correct.Miax_Pearl.tar.gz"
     "engine/Testing/TestModels/TMS74GridTests/refdata/s74output_correct/correct.Miax_Pearl.tar.gz"))
 '(redisplay-dont-pause t t)
 '(request-curl-options '("-k"))
 '(ring-bell-function nil)
 '(safe-local-variable-directories
   '("/home/STRIKETECH/ejohnson/workspace_git/GTS51/"
     "/home/STRIKETECH/ejohnson/workspace_git/engine/"
     "/home/STRIKETECH/ejohnson/workspace_git/ui/"))
 '(safe-local-variable-values
   '((eej-modeline-project-branch-face .
                                       eej-modeline-project-branch-face-4)
     (eej-modeline-project-branch-face .
                                       eej-modeline-project-branch-face-1)
     (flycheck-disabled-checkers emacs-lisp-checkdoc)
     (eej-modeline-project-branch-face .
                                       eej-modeline-project-branch-face-2)))
 '(show-paren-style 'expression)
 '(show-paren-when-point-in-periphery t)
 '(show-paren-when-point-inside-paren t)
 '(transient-mark-mode 1)
 '(undo-tree-history-directory-alist '((".*" . "~/tmp/")))
 '(user-full-name "Eric Johnson")
 '(user-mail-address (getenv "EEJ_EMAIL"))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   '((20 . "#BC8383") (40 . "#CC9393") (60 . "#DFAF8F") (80 . "#D0BF8F")
     (100 . "#E0CF9F") (120 . "#F0DFAF") (140 . "#5F7F5F")
     (160 . "#7F9F7F") (180 . "#8FB28F") (200 . "#9FC59F")
     (220 . "#AFD8AF") (240 . "#BFEBBF") (260 . "#93E0E3")
     (280 . "#6CA0A3") (300 . "#7CB8BB") (320 . "#8CD0D3")
     (340 . "#94BFF3") (360 . "#DC8CC3")))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(vc-follow-symlinks nil)
 '(visible-bell nil)
 '(warning-suppress-log-types '((corfu-doc)))
 '(whitespace-line-column 220)
 '(whitespace-style '(face tabs lines-char indentation::space)))
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
  :hook
  ;; This hook is acting funny. It doesn't always apply for elisp buffers
  (prog-mode . (lambda () "Enables flymake mode for all programming modes" (flymake-mode +1)))
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

;; A few more useful configurations...
(use-package emacs
  :init
  ;; TAB cycle if there are only few candidates
  (setq completion-cycle-threshold 3)
  (put 'downcase-region 'disabled nil)
  (put 'upcase-region 'disabled nil)
  (put 'compilation-search-path 'safe-local-variable 'string-or-null-p)
  :hook
  (prog-mode . (lambda () ""
                 (setq-default indent-tabs-mode nil)
                 (setq buffer-display-table (make-display-table))
                 (aset buffer-display-table ?\^M [])
                 ;;(global-hl-line-mode nil)
                 (display-line-numbers-mode t)
                 ;; TODO:  Need to figure out how make whitespace mode useful
                 (whitespace-mode t)
                 (electric-pair-local-mode t)
                 (highlight-parentheses-mode t)))
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

(straight-use-package 'marginalia)
(use-package marginalia
  :config
  (marginalia-mode t))

(straight-use-package 'which-key)
(use-package which-key
  :config
  (which-key-mode t)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-side-window-location 'bottom))


;; TODO: Copied from https://github.com/oantolin/embark
(straight-use-package 'embark)
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

(straight-use-package 'yaml-mode)
(use-package yaml-mode)

;; This provides colors to rgb color parameters
(straight-use-package 'rainbow-mode)
(use-package rainbow-mode
  :config
  (add-hook 'emacs-lisp-mode-hook (lambda () (rainbow-mode t))))

;; Not sure what these are for or if we need them
;; `vertico-previous'.
;;(keymap-set vertico-map "M-q" #'vertico-quick-insert)
;;(keymap-set vertico-map "C-q" #'vertico-quick-exit)

;; Can this be moved into the org specific configs?
(defvar eej-org-mode-map (make-sparse-keymap) "Keymap for eej-org-mode-map.")
(define-minor-mode eej-org-mode
  "A minor mode to bring the shift arrows keys with windmove mode active."
  :init-value nil
  :keymap eej-org-mode-map)

(define-key eej-org-mode-map (kbd "S-<down>") #'org-shiftdown)
(define-key eej-org-mode-map (kbd "S-<left>") #'org-shiftleft)
(define-key eej-org-mode-map (kbd "S-<right>") #'org-shiftright)
(define-key eej-org-mode-map (kbd "S-<up>") #'org-shiftup)


;;; CODE:
(defun eej/find-stuck-projects ()
  "A project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO."
  (let ((at-least-one-action (save-excursion (org-agenda-skip-subtree-if 'todo '("STARTED" "WAITING" "NEXT"))))
        (at-least-one-done (save-excursion (org-agenda-skip-subtree-if 'todo 'done)))
        (at-least-one-scheduled (save-excursion (org-agenda-skip-subtree-if 'scheduled))))
    (if (and at-least-one-done (not at-least-one-action) (not at-least-one-scheduled))
        nil
      (or (outline-next-heading) (org-end-of-subtree t)))))

;; org-element-map - could be good...
;; org-map-entries is a little better - easier to work with
;; org-entry-get - nope - not it
;; org-element-at-point - this gets a list

(defun eej/is-todo-scheduled ()
  "Is this an incomplete todo with a scheduled date."
  (let* ((element (org-element-at-point))
         (todo-type (org-element-property :todo-type element))
         (scheduled (org-element-property :scheduled element)))
    (if (and (eq todo-type 'todo) scheduled)
        (point)
      nil)))

(defun eej/find-nested-started ()
  "A project has at least one DONE task and no child STARTED|WAITING|NEXT or any scheduled TODO."  
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

(defun eej/recompute-clock-sum ()
  "Recomputes the clock sum time for the projects buffer."
  (save-window-excursion
    ;; Is there a better way to find this buffer? Seems... clumsy
    (switch-to-buffer "projects.org")
    (goto-char 1)
    (org-clock-sum (org-read-date nil nil "-3w"))))

;; Perhaps of use for some work files
(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(put 'narrow-to-region 'disabled nil)

;; TODO: Is there a way to get this into use-package?
;;(load-file "modeline.el")
(require 'local-config "~/.emacs.d/local-config.el")

;;(add-to-list 'eglot-server-programs '(c++-ts-mode . ("clangd" "--log=verbose --path-mappings=Vulcan/=engine/Vulcan/")))
