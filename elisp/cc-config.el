(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))
(add-to-list 'load-path "~/devenv/elisp/cc-mode/")
;; Enables the return key to continue comments or strings
(add-hook 'c-initialization-hook (lambda () "" (define-key c-mode-base-map "\C-m" 'c-context-line-break)))

(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(prelude-require-packages '(rainbow-delimiters))
(defun my-c-mode-common-hook ()
  (remove-dos-eol)
  (font-lock-mode 2)
  (global-hl-line-mode -1)
  (highlight-parentheses-mode t)
  (rainbow-delimiters-mode +1))

(add-hook 'c++-mode-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-hook 'my-c-mode-common-hook)
(provide 'cc-config)
