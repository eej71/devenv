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
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(redisplay-dont-pause t t)
 '(request-curl-options '("-k"))
 '(ring-bell-function nil)
 '(safe-local-variable-values
   '((eval face-remap-add-relative 'font-lock-function-call-face
	   :foreground "#9bbfe8" :italic nil)
     (eval face-remap-add-relative 'font-lock-function-call-face
	   :foreground "#c490d1" :background "#1a0a2e" :italic nil)
     (eval face-remap-add-relative 'font-lock-function-call-face
	   :foreground "#6cb4e4" :italic nil)
     (flycheck-disabled-checkers emacs-lisp-checkdoc)))
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
 '(warning-suppress-types '((native-compiler)))
 '(whitespace-line-column 220)
 '(whitespace-style '(face tabs lines-char indentation::space trailing)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
