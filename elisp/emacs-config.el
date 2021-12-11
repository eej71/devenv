(require 'uniquify)
(require 'projectile)
(require 'toggle-source)
(require 'cc-config)
(require 'company)
(require 'spectral-theme)
(require 'org-config)
(require 'local-config)
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
 '(custom-file "~/devenv/elisp/emacs-config.el")
 '(custom-safe-themes
   '("4219e359bae5bea2a683b3b310cf73fb7463d554558aaccf5660a5680ca76c53" "2887f73fc0a89beaa18688aad1ad019505c0b12aeba5137edb16cb03f32fbc8b" "13c47ed0d5e869b2feec4d0dc4ea85e90c368f179d31c06fdb47024e5567c44d" "7218af3d77fc674a5f97d139602eabb5a1a8309b7a4daa6096a9a9e504d00bac" "f84ee8bb083475063b643683475f706df42d8ffda4c740d68d9bfbfc687b2cda" "83bc3941e4818bdeb8e7cf5f2004c6df074e8d1ef11bcd377c216ce09b79dd2c" "c33a497ccd1c131b60ed7c5862c88629c459867e455cc9ae248d1944e3675b1b" "319fc505eaf7556a9882d38a2f5d4d2cddad65b605668e6efbe5ed0ccdd0a5bd" "b80abf8d5a52d81203383575bd8ca15777bd5e5c602dd757dc1ff539f18cc353" "cae15efb443ee0b3d16ded7f0ad1fafd0562236a9e55bd622f5b39f8c4415541" "769f3b15c41931a29210f462f554e6168d76ee098e0e7c36cad8293548ea75dd" "d4f9bc75ab183f3f0cc8660c264e3483a8bb4c7090a4a8971888f7f7b068bd4b" "b103fc29dc671f519feb4e5ba71d84fc29032db0b73f8788d4bf64344d7d9f53" "b8ca35a069b4252c25cc9fcfd6e21d030ae190fd5a25c29a9ac062718a4530f2" "c2d4bcab3edf73fed7a28211547ff6f3f943900400b727f5b7d0505c4add1330" "90244bef6fa8785e1f963b4e347edd7bbe922bc4d96bc2458c472956358ab5dc" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "2930dff004a27127fc167b1747d459b7a959b5baba3ec533881fb57e87244205" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "d6922c974e8a78378eacb01414183ce32bc8dbf2de78aabcc6ad8172547cb074" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "718fb4e505b6134cc0eafb7dad709be5ec1ba7a7e8102617d87d3109f56d9615" "2022c5a92bbc261e045ec053aa466705999863f14b84c012a43f55a95bf9feb8" "63151d1866700f4f4bf2aa5f845e79677e1fe80dd7136c408634a280ec85f902" "770e16452f34c14455950535982350ec5980f5f113ba1574f4658c930e20c69e" "3728fd3ce10b4c0bdfd320962336f96cef112de554a00f9cc9875a27f12589e3" "6369644497a7dde1350dce08f404316c7cb19f2d1c1b937d412a8860c4eb02f5" "c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "0820d191ae80dcadc1802b3499f84c07a09803f2cb90b343678bdb03d225b26b" default))
 '(display-line-numbers-grow-only t)
 '(display-line-numbers-width 3)
 '(exec-path-from-shell-check-startup-files nil)
 '(fci-rule-color "#383838")
 '(flycheck-color-mode-line-face-to-color 'mode-line-buffer-id)
 '(font-lock-maximum-decoration t)
 '(gtags-suggested-key-mapping t)
 '(helm-echo-input-in-header-line nil)
 '(helm-ff-file-name-history-use-recentf t)
 '(helm-ff-search-library-in-sexp t)
 '(helm-move-to-line-cycle-in-source t)
 '(helm-scroll-amount 8)
 '(helm-split-window-inside-p t)
 '(inhibit-startup-screen t)
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
 '(org-agenda-start-with-clockreport-mode t)
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
 '(org-tag-alist '(("work" . 119) ("home" . 104)))
 '(org-tags-column 120)
 '(org-tags-exclude-from-inheritance '("project"))
 '(org-tags-match-list-sublevels t)
 '(org-time-clocksum-format
   '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))
 '(org-use-speed-commands t)
 '(org-use-tag-inheritance t)
 '(package-selected-packages
   '(company-anaconda anaconda-mode rainbow-mode elisp-slime-nav rainbow-delimiters company helm-ag helm-descbinds helm-projectile helm zop-to-char zenburn-theme which-key volatile-highlights undo-tree super-save smartrep smartparens projectile operate-on-number move-text magit imenu-anywhere hl-todo guru-mode gitignore-mode gitconfig-mode git-timemachine gist flycheck expand-region exec-path-from-shell editorconfig easy-kill discover-my-major diminish diff-hl crux browse-kill-ring anzu ag ace-window))
 '(pdf-view-midnight-colors '("#DCDCCC" . "#383838"))
 '(prelude-clean-whitespace-on-save nil)
 '(prelude-guru nil)
 '(projectile-enable-caching t)
 '(projectile-globally-ignored-files nil)
 '(projectile-known-projects nil t)
 '(projectile-mode-line nil)
 '(recentf-max-menu-items 50)
 '(recentf-max-saved-items 50)
 '(redisplay-dont-pause t t)
 '(rm-blacklist
   '(" hl-p" " EL" " company" " EditorConfig" " Pre" " WK" " ws" " C++" " SP" " Abbrev" "C++/l" " (*)" " Helm" "SP/s" " SP/s" " ARev" " Isearch"))
 '(sml/modified-char "X")
 '(sml/mule-info "")
 '(sml/name-width '(5 . 50))
 '(sml/position-percentage-format "%6p")
 '(sml/replacer-regexp-list nil)
 '(transient-mark-mode 1)
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
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(add-hook 'message-mode-hook '(lambda () "" (auto-fill-mode)))
(add-hook 'mail-mode-hook '(lambda () "" (auto-fill-mode)))
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

(when (fboundp 'windmove-default-keybindings)  (windmove-default-keybindings 'meta))

(tool-bar-mode nil)
(recentf-mode t)
(global-auto-revert-mode t)
(global-flycheck-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)

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
(global-set-key (kbd "C-x C-r") 'helm-for-files)
(global-set-key [f1] 'compile)
(global-set-key [f2] 'next-error)
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i")   'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")   'helm-select-action) ; list actions using C-z

(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)

;; Why won't my configs work?
(global-nlinum-mode -1)
(menu-bar-mode -1)
(global-display-line-numbers-mode) ;; Requires emacs 26

(provide 'emacs-config)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
