(require 'uniquify)
(require 'projectile)
(require 'toggle-source)
(require 'cc-config)
(require 'company)
(require 'spectral-theme)
(require 'org-config)
(require 'local-config)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'projectile-project-compilation-cmd 'safe-local-variable 'string-or-null-p)
(put 'compilation-search-path 'safe-local-variable 'string-or-null-p)

(add-hook 'message-mode-hook (lambda () "" (auto-fill-mode)))
(add-hook 'mail-mode-hook (lambda () "" (auto-fill-mode)))
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(when (fboundp 'windmove-default-keybindings)  (windmove-default-keybindings 'meta))

(tool-bar-mode -1)
(recentf-mode t)
(global-auto-revert-mode t)
(global-flycheck-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode -1)

;; Enables daisy chaining of .dir-locals.el files. Most was copied from here
;; http://emacs.stackexchange.com/questions/5527/is-there-a-way-to-daisy-chain-dir-locals-el-files
(defvar walk-dir-locals-upward nil
    "If non-nil, evaluate .dir-locals.el files starting in the
  current directory and going up. Otherwise they will be
  evaluated from the top down to the current directory.")

(defadvice hack-dir-local-variables (around walk-dir-locals-file activate)
  (let* ((dir-locals-list (list dir-locals-file))
         (walk-dir-locals-file (car dir-locals-list)))
    (while (not (equal (concat "/" dir-locals-file) (expand-file-name walk-dir-locals-file)))
      (progn
        (setq walk-dir-locals-file (concat "../" walk-dir-locals-file))
        (if (file-readable-p walk-dir-locals-file)
            (add-to-list 'dir-locals-list walk-dir-locals-file
                         walk-dir-locals-upward))
        ))
    (dolist (file dir-locals-list)
      (let ((dir-locals-file (expand-file-name file)))
        ad-do-it
        )))
  )

(global-set-key (kbd "C-s") 'isearch-forward)
(global-set-key [f1] 'compile)
(global-set-key [f2] 'next-error)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)

(menu-bar-mode -1)


(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(provide 'emacs-config)
