(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ack-and-a-half-arguments '("--ignore-dir=release --ignore-dir=debug"))
 '(ansi-color-faces-vector
   [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
   ["#3F3F3F" "#CC9393" "#7F9F7F" "#F0DFAF" "#8CD0D3" "#DC8CC3" "#93E0E3" "#DCDCCC"])
 '(backup-directory-alist (list '(".*" . "~/tmp/")))
 '(beacon-color "#cc6666")
 '(company-minimum-prefix-length 5)
 '(company-quickhelp-color-background "#DCDCCC")
 '(company-quickhelp-color-foreground "#4F4F4F")
 '(company-show-quick-access t)
 '(company-tooltip-limit 20)
 '(compilation-skip-threshold 1)
 '(completion-ignore-case t t)
 '(custom-enabled-themes '(spectral))
 '(custom-safe-themes t)
 '(custom-theme-directory "~/devenv/elisp/")
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width 3)
 '(exec-path-from-shell-check-startup-files nil)
 '(fci-rule-color "#383838")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(font-lock-maximum-decoration t)
 '(global-display-line-numbers-mode nil)
 '(gtags-suggested-key-mapping t)
 '(highlight-parentheses-attributes '((:underline t)))
 '(highlight-parentheses-colors nil)
 '(inhibit-startup-screen t)
 '(magit-diff-refine-hunk 'all)
 '(mode-line-format
   '(" " mode-line-position mode-line-modified mode-line-frame-identification mode-line-buffer-identification sml/pos-id-separator smartrep-mode-line-string
     (vc-mode vc-mode)
     sml/pre-modes-separator mode-line-modes mode-line-misc-info mode-line-end-spaces))
 '(mode-line-misc-info (reverse mode-line-misc-info) t)
 '(nrepl-message-colors
   '("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3"))
 '(org-agenda-block-separator "")
 '(org-agenda-files '("~/org/projects.org"))
 '(org-agenda-log-mode-add-notes nil)
 '(org-agenda-log-mode-items '(clock))
 '(org-agenda-remove-tags t)
 '(org-agenda-sorting-strategy
   '((agenda habit-down time-up priority-down category-keep)
     (todo todo-state-down priority-down category-keep)
     (tags priority-down category-keep)
     (search category-keep)))
 '(org-agenda-start-with-clockreport-mode t)
 '(org-agenda-tags-column 150)
 '(org-checkbox-hierarchical-statistics nil)
 '(org-clock-history-length 10)
 '(org-clock-into-drawer t)
 '(org-clock-mode-line-total 'today)
 '(org-clock-modeline-total 'today)
 '(org-clock-out-remove-zero-time-clocks t)
 '(org-clock-persist t)
 '(org-clock-persist-file "~/org/org-clock-save.el")
 '(org-columns-default-format "%100ITEM %TODO %TAGS")
 '(org-deadline-warning-days 3)
 '(org-default-notes-file (concat org-directory "/notes.org"))
 '(org-directory "~/org")
 '(org-hide-leading-stars t)
 '(org-hierarchical-checkbox-statistics nil)
 '(org-log-done 'time)
 '(org-log-into-drawer t)
 '(org-log-note-clock-out nil)
 '(org-outline-path-complete-in-steps nil)
 '(org-refile-use-outline-path 4)
 '(org-return-follows-link t)
 '(org-reverse-note-order t)
 '(org-startup-indented t)
 '(org-tag-alist '(("work" . 119) ("home" . 104)))
 '(org-tags-column 120)
 '(org-tags-exclude-from-inheritance '("project"))
 '(org-tags-match-list-sublevels t)
 '(org-time-clocksum-format
   '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))
 '(org-use-speed-commands t)
 '(org-use-tag-inheritance t)
 '(package-selected-packages
   '(highlight-parentheses vertico 0blayout ace-window ag anaconda-mode anzu auto-complete beacon browse-kill-ring chess color-theme-sanityinc-solarized color-theme-sanityinc-tomorrow company company-anaconda consult consult-company consult-lsp consult-projectile counsel crux csv-mode d-mode diff-hl diminish discover-my-major easy-kill editorconfig elisp-slime-nav evil-visualstar exec-path-from-shell expand-region flatui-dark-theme flx-ido flycheck geiser ggtags gist git-timemachine gitconfig-mode gitignore-mode go-projectile god-mode goto-chg grizzl guru-mode helm helm-ag helm-descbinds helm-git helm-git-files helm-git-grep helm-gtags helm-make helm-org-rifle helm-orgcard helm-projectile helm-rg hl-todo ido-ubiquitous ido-vertical-mode iedit imenu-anywhere ivy js2-mode json-mode key-chord lush-theme magit magit-popup markdown-mode merlin move-text operate-on-number orderless org org-jira org-roam org-roam-bibtex org-roam-timestamps org-roam-ui ov projectile projectile-ripgrep protobuf-mode rainbow-delimiters rainbow-mode rg ripgrep selectrum selectrum-prescient smart-mode-line smart-mode-line-powerline-theme smartparens smartrep smex solarized-theme spaceline super-save swiper transient tuareg undo-tree utop vkill volatile-highlights w3 w3m web-mode which-key yaml-mode zenburn-theme zop-to-char))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(prelude-clean-whitespace-on-save nil)
 '(prelude-guru nil)
 '(projectile-enable-caching t)
 '(projectile-globally-ignored-files nil)
 '(projectile-keymap-prefix (kbd "C-c p"))
 '(projectile-known-projects nil t)
 '(projectile-mode-line nil)
 '(rainbow-delimiters-max-face-count 8)
 '(recentf-max-menu-items 50)
 '(recentf-max-saved-items 50)
 '(redisplay-dont-pause t t)
 '(request-curl-options '("-k"))
 '(rm-blacklist
   '(" hl-p" " EL" " company" " EditorConfig" " Pre" " WK" " ws" " C++" " SP" " Abbrev" "C++/l" " (*)" " Helm" "SP/s" " SP/s" " ARev" " Isearch" " Anaconda" " Server" " Narrow" " Ind"))
 '(selectrum-extend-current-candidate-highlight t)
 '(show-paren-style 'expression)
 '(sml/modified-char "X")
 '(sml/mule-info "")
 '(sml/name-width '(5 . 50))
 '(sml/position-percentage-format "%6p")
 '(sml/replacer-regexp-list nil)
 '(transient-mark-mode 1)
 '(undo-tree-history-directory-alist '((".*" . "~/tmp/")))
 '(uniquify-buffer-name-style 'post-forward-angle-brackets nil (uniquify))
 '(user-full-name "Eric Johnson")
 '(user-mail-address (getenv "EEJ_EMAIL"))
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-color-map
   '((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3")))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(vc-follow-symlinks nil)
 '(visible-bell t)
 '(whitespace-line-column 220))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'load-path "~/devenv/elisp/")
(require 'emacs-config)
