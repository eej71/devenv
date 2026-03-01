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

;; Domain modules (Org, editor utilities, Copilot Chat extensions).
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(require 'editor-utilities)
(require 'org-custom)
(require 'copilot-chat-custom)

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
  (major-mode-remap-alist '((c++-mode . c++-ts-mode) (c-mode . c-ts-mode) (c-or-c++-mode . c++-ts-mode)))
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
        aw-background t
        aw-dispatch-always t
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
 '(package-vc-selected-packages
   '((copilot :url "https://github.com/copilot-emacs/copilot.el" :branch "main")))
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
(global-set-key (kbd "C-c h") 'eej-resize-window-hydra)

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
(dolist (path '("/usr/local/bin" "/home/WORKNAME/.nvm/versions/node/v20.20.0/bin"))
  (add-to-list 'exec-path path)
  (unless (string-match-p (regexp-quote path) (or (getenv "PATH") ""))
    (setenv "PATH" (concat path ":" (or (getenv "PATH") "")))))

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
  (eej/copilot-chat-enable))

;; Not sure what these are for or if we need them
;; `vertico-previous'.
;;(keymap-set vertico-map "M-q" #'vertico-quick-insert)
;;(keymap-set vertico-map "C-q" #'vertico-quick-exit)

(put 'narrow-to-region 'disabled nil)

;; TODO: Is there a way to get this into use-package?
;;(load-file "modeline.el")
(require 'local-config "~/.emacs.d/local-config.el")
