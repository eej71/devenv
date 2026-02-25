;;; ui-chrome.el --- Visual appearance and window management -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Theme, modeline, window management, and general UI configuration.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

(use-package spectral-theme
  :straight nil
  :init
  (add-to-list 'custom-theme-load-path "~/.emacs.d/")
  (require 'modeline (expand-file-name "modeline" user-emacs-directory))
  (load-theme 'spectral t))

(use-package windmove
  :config
  (windmove-mode)
  (windmove-default-keybindings)
  :custom
  (windmove-wrap-around t))

(use-package ace-window
  :bind (("M-o" . ace-window)
         ("C-x o" . ace-window))   ;; replace default other-window
  :config
  ;; Don't use ace-window-display-mode — it destructures mode-line-format
  ;; with ,@ splicing, which breaks our single (:eval …) custom modeline.
  ;; The custom modeline already includes the ace-window path display.
  (aw-update)
  (add-hook 'window-configuration-change-hook #'aw-update)
  (add-hook 'after-make-frame-functions #'aw--after-make-frame t)
  (setq aw-keys '(?a ?s ?d ?f ?j ?k ?l)
        aw-background t
        aw-dispatch-always t
        aw-split-style 'fair))

(use-package which-key
  :config
  (which-key-mode t)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-side-window-location 'bottom))

(use-package recentf
  :config
  (recentf-mode t)
  (run-at-time nil 600 'recentf-save-list)
  :custom
  (recentf-max-menu-items 50
   recentf-max-saved-items 50))

;; Disable GUI chrome
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

;; Global keybindings
(global-set-key [f7] 'set-mark-command)
(global-set-key (kbd "C-x z") 'ff-get-other-file)
(global-set-key (kbd "C-c h") 'eej-resize-window-hydra)

(provide 'ui-chrome)
;;; ui-chrome.el ends here
