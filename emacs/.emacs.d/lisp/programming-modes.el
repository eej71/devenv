;;; programming-modes.el --- Programming language support -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Tree-sitter, Corfu, Flymake, formatting, and programming mode hooks.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

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
  :custom
  (major-mode-remap-alist '((c++-mode . c++-ts-mode) (c-mode . c-ts-mode) (c-or-c++-mode . c++-ts-mode)))
  (c-ts-mode-indent-style #'eej-indent-style)
  (treesit-font-lock-level 4))

;; Corfu — in-buffer completion
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
  (corfu-cycle t)
  (corfu-scroll-margin 5)
  (corfu-count 20))

(use-package yasnippet
  :hook (org-mode . yas-minor-mode)
  :bind (:map yas-minor-mode-map
              ("M-/" . eej/yas-expand-or-dabbrev))
  :config
  (defun eej/yas-expand-or-dabbrev ()
    "Try yasnippet expansion, fall back to dabbrev-expand."
    (interactive)
    (unless (yas-expand)
      (dabbrev-expand nil))))

;; Flymake — on-the-fly syntax checking
(use-package flymake)

(use-package clang-format)

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  :custom
  ;; We are limited to a total of 9 faces - so we just skip every other color group
  (rainbow-x-colors nil) ;; Dislike the names of colors being colored
  (rainbow-delimiters-max-face-count 7))

(use-package smartparens)

(use-package yaml-mode)

(use-package rainbow-mode
  :config
  (add-hook 'emacs-lisp-mode-hook #'spectral-enable-colorized-words))

(use-package buttercup)

;; Programming mode hooks
(add-hook 'prog-mode-hook #'eej/prog-mode-setup)
(add-hook 'nxml-mode-hook #'eej/prog-mode-setup)
(add-hook 'c-initialization-hook
          (lambda () (define-key c-mode-base-map "\C-m" 'c-context-line-break)))

(provide 'programming-modes)
;;; programming-modes.el ends here
