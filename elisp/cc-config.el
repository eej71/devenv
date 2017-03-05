(setq auto-mode-alist (cons '("\\.h\\'" . c++-mode) auto-mode-alist))

;; Enables the return key to continue comments or strings
(add-hook 'c-initialization-hook '(lambda () "" (define-key c-mode-base-map "\C-m" 'c-context-line-break)))

(defun remove-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (setq buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M []))

(defun my-c-mode-common-hook ()
  (linum-mode t)
  (remove-dos-eol)
  (font-lock-mode 2))

(add-hook 'prelude-mode-hook 'my-c-mode-common-hook)
(provide 'cc-config)
