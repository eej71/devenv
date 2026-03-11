;;; completion-framework.el --- Minibuffer completion stack -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Vertico, Consult, Orderless, Marginalia, and Embark configuration.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

(use-package orderless
  :custom
  (read-file-name-completion-ignore-case t)
  (read-buffer-completion-ignore-case t)
  (completion-ignore-case t)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion))))
  (orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex)))

(use-package vertico
  :straight (vertico :files (:defaults "extensions/*")
                     :includes (vertico-directory
                                vertico-indexed
                                vertico-quick
                                vertico-repeat))
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
  :straight nil
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Jump to a candidate by typing a two-character avy-style label.
(use-package vertico-quick
  :after vertico
  :straight nil
  :bind (:map vertico-map
              ("M-q" . vertico-quick-jump)))

;; Resume the last minibuffer session.
(use-package vertico-repeat
  :after vertico
  :straight nil
  :bind (("M-r" . vertico-repeat)
         :map vertico-map
         ("M-r" . vertico-repeat-next)
         ("M-R" . vertico-repeat-previous))
  :hook (minibuffer-setup . vertico-repeat-save))

(use-package savehist
  :straight nil
  :init
  (savehist-mode))

(use-package consult
  :bind
  ("C-x b"   . consult-buffer)
  ("C-x r b" . consult-bookmark)
  ("C-x r s" . consult-register-store)
  ("C-x r j" . consult-register-load)

  ("M-g g"   . consult-goto-line)
  ("M-g i"   . consult-imenu)
  ("M-g I"   . consult-imenu-multi)
  ("M-g o"   . consult-outline)

  ("C-c s f" . consult-find)
  ("C-c s g" . consult-grep)
  ("C-c s G" . consult-git-grep)
  ("C-c s l" . consult-line)
  ("C-c s L" . consult-line-multi)
  ("C-c s k" . consult-keep-lines)
  ("C-c s o" . consult-org-heading)
  ("C-c s r" . consult-ripgrep)
  ("C-c s u" . consult-focus-lines)

  :config
  (setq consult-narrow-key "<")
  (setq consult-ripgrep-args "rg --null --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --no-search-zip")

  ;; Avoid eager preview when traversing large codebases.
  (consult-customize consult-ripgrep consult-grep consult-git-grep consult-find
                     :preview-key "M-.")

  (advice-add #'project-find-regexp :override #'consult-ripgrep)

  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package consult-project-extra
  :bind
  (("C-x p f" . consult-project-extra-find)
   ("C-x p o" . consult-project-extra-find-other-window)))

(use-package marginalia
  :config
  (marginalia-mode t))

(use-package xref
  :straight nil
  :bind
  (("M-." . xref-find-definitions)
   ("M-," . xref-go-back)))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-c ." . embark-dwim)
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
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(provide 'completion-framework)
;;; completion-framework.el ends here
