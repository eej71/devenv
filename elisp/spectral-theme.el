(deftheme spectral)

(let* ((spectral/background   "#000000")
       (spectral/background+5 "#121212")
       (spectral/foreground   "#FFFFFF")
       (spectral/turquoise    "#00Af87")
       (spectral/orange       "#FF951B")
       (spectral/pink         "#FF88FF")
       (spectral/yellow       "#d7ff00")
       (spectral/green        "#61CE3C")
       (spectral/light-blue   "#82A6DF")
       (spectral/lightblue-2  "#00ffff")
       (spectral/skyblue      "#00afff")
       (spectral/dark-blue    "#284050")
       (spectral/light-red    "#FA583F")
       (spectral/limegreen-1  "#87ffaf")
       (spectral/preprocessor "#FF005F")
       (spectral/salmon    "#d75f5f")
       (spectral-fg+1     "#FFFFEF")
       (spectral-fg       "#DCDCCC")
       (spectral-fg-1     "#656555")
       (spectral-bg-2     "#000000")
       (spectral-bg-1     "#1B1B1B")
       (spectral-bg-03    "#292929")
       (spectral-bg-05    "#383838")
       (spectral-bg       "#3F3F3F")
       (spectral-bg+05    "#494949")
       (spectral-bg+1     "#4F4F4F")
       (spectral-bg+2     "#5F5F5F")
       (spectral-bg+3     "#6F6F6F")
       (spectral-red+1    "#DCA3A3")
       (spectral-red      "#CC9393")
       (spectral-red-1    "#BC8383")
       (spectral-red-2    "#AC7373")
       (spectral-red-3    "#9C6363")
       (spectral-red-4    "#8C5353")
       (spectral-orange   "#DFAF8F")
       (spectral-yellow   "#F0DFAF")
       (spectral-yellow-1 "#E0CF9F")
       (spectral-yellow-2 "#D0BF8F")
       (spectral-green-1  "#5F7F5F")
       (spectral-green    "#7F9F7F")

       (spectral-green+1  "#8FB28F")
       (spectral-green+2  "#9FC59F")
       (spectral-green+3  "#AFD8AF")
       (spectral-green+4  "#BFEBBF")
       (spectral-cyan     "#93E0E3")
       (spectral-blue+1   "#94BFF3")
       (spectral-blue     "#8CD0D3")
       (spectral-blue-1   "#7CB8BB")
       (spectral-blue-2   "#6CA0A3")
       (spectral-blue-3   "#5C888B")
       (spectral-blue-4   "#4C7073")
       (spectral-blue-5   "#366060")
       (spectral-magenta  "#DC8CC3")
       (separator-left
        '(intern (format "powerline-%s-%s"
                         (powerline-current-separator)
                         (car powerline-default-separator-dir))))
       )

  ;; where is the face
  (custom-theme-set-faces
   'spectral
   `(bold                         ((t (:bold t))))
   `(bold-italic                  ((t (:bold t))))
   `(border-glyph                 ((t (nil))))
   `(default                      ((t (:foreground ,spectral/foreground :background ,spectral/background))))
   `(fringe                       ((t (:background ,spectral/background))))
   `(buffers-tab                  ((t (:foreground ,spectral/foreground :background ,spectral/background))))
   `(font-lock-builtin-face       ((t (:foreground "Khaki" :weight bold))))
   `(font-lock-comment-face       ((t (:foreground ,spectral/limegreen-1 :background ,spectral/background+5 :italic t))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,spectral/limegreen-1 :background ,spectral/background+5 :bold t))))
   `(font-lock-doc-face           ((t (:foreground "SlateGray"))))
   `(font-lock-doc-string-face    ((t (:foreground ,spectral/orange))))
   `(font-lock-string-face        ((t (:foreground ,spectral/green :italic t))))
   `(font-lock-function-name-face ((t (:foreground ,spectral/pink :background ,spectral/background+5))))
   `(font-lock-keyword-face       ((t (:foreground ,spectral/yellow :bold t))))
   `(font-lock-preprocessor-face  ((t (:foreground ,spectral/preprocessor :background ,spectral/background+5))))
   `(font-lock-constant-face      ((t (:foreground ,spectral/light-blue))))
   `(font-lock-type-face          ((t (:foreground ,spectral/light-blue))))
   `(font-lock-variable-name-face ((t (:foreground ,spectral/lightblue-2))))
   `(font-lock-negation-char-face ((t (:foreground ,spectral/pink))))
   `(font-lock-warning-face       ((t (:foreground "Pink"     :bold t))))
   `(gui-element                  ((t (:foreground "black"    :background "#D4D0C8"))))

   `(text-cursor                  ((t (:foreground "black" :background "yellow"))))
   `(region                       ((t (:background ,spectral-bg-1))))
   `(highlight                    ((t (:background "#222222"))))
   `(highline-face                ((t (:background "SeaGreen"))))
   `(hl-line                      ((t (:background "black"))))
   `(italic                       ((t (nil))))
   `(left-margin                  ((t (nil))))
   `(toolbar                      ((t (nil))))

   ;; This captures the headline levels of org mode
   `(org-level-1                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-2                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-3                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-4                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-5                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-6                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-7                  ((t (:background "black" :foreground ,spectral/foreground))))
   `(org-level-8                  ((t (:background "black" :foreground ,spectral/foreground))))

   ;; Not reviewed or verified
   `(compilation-column-face ((t (:foreground ,spectral-yellow))))
   `(compilation-enter-directory-face ((t (:foreground ,spectral-green))))
   `(compilation-error-face ((t (:foreground ,spectral-red-1 :weight bold :underline t))))
   `(compilation-face ((t (:foreground ,spectral-fg))))
   `(compilation-info-face ((t (:foreground ,spectral-blue))))
   `(compilation-info ((t (:foreground ,spectral-green+4 :underline t))))
   `(compilation-leave-directory-face ((t (:foreground ,spectral-green))))
   `(compilation-line-face ((t (:foreground ,spectral-yellow))))
   `(compilation-line-number ((t (:foreground ,spectral-yellow))))
   `(compilation-message-face ((t (:foreground ,spectral-blue))))
   `(compilation-warning-face ((t (:foreground ,spectral-orange :weight bold :underline t))))
   `(compilation-mode-line-exit ((t (:foreground ,spectral-green+2 :weight bold))))
   `(compilation-mode-line-fail ((t (:foreground ,spectral-red :weight bold))))
   `(compilation-mode-line-run ((t (:foreground ,spectral-yellow :weight bold))))

   ;;
   `(completions-annotations ((t (:foreground ,spectral-fg-1))))
   `(grep-context-face ((t (:foreground ,spectral-fg))))
   `(grep-error-face ((t (:foreground ,spectral-red-1 :weight bold :underline t))))
   `(grep-hit-face ((t (:foreground ,spectral-blue))))
   `(grep-match-face ((t (:foreground ,spectral-orange :weight bold))))
   `(match ((t (:background ,spectral-bg-1 :foreground ,spectral-orange :weight bold))))

   `(hi-blue    ((t (:background ,spectral-cyan    :foreground ,spectral-bg-1))))
   `(hi-green   ((t (:background ,spectral-green+4 :foreground ,spectral-bg-1))))
   `(hi-pink    ((t (:background ,spectral-magenta :foreground ,spectral-bg-1))))
   `(hi-yellow  ((t (:background ,spectral-yellow  :foreground ,spectral-bg-1))))
   `(hi-blue-b  ((t (:foreground ,spectral-blue    :weight     bold))))
   `(hi-green-b ((t (:foreground ,spectral-green+2 :weight     bold))))
   `(hi-red-b   ((t (:foreground ,spectral-red     :weight     bold))))

   `(Info-quoted ((t (:inherit font-lock-constant-face))))
;;;;; isearch
   `(isearch ((t (:foreground ,spectral/light-red :bold t :underline t :italic t))))
   `(isearch-fail ((t (:foreground ,spectral-fg :background ,spectral-red-4))))
   `(lazy-highlight ((t (:foreground ,spectral-yellow-2))))

   `(menu ((t (:foreground ,spectral-fg :background ,spectral-bg))))
   `(minibuffer-prompt ((t (:foreground ,spectral-yellow))))

   '(mode-line ((t (:background "#353535" :box (:line-width 2 :color "#009845" :style released-button)))))
   '(mode-line-inactive ((t (:background "#1f1f1f" :foreground "#707070" :box (:line-width -1 :color "#080808" :style released-button)))))
   ;; `(region ((,class (:background ,spectral-bg-1)) (t :inverse-video t)))
   `(secondary-selection ((t (:background ,spectral-bg+2))))
   `(trailing-whitespace ((t (:background ,spectral-red))))
   `(vertical-border ((t (:foreground ,spectral-fg))))

;;;;; font lock
   `(font-lock-negation-char-face ((t (:foreground ,spectral-yellow :weight bold))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,spectral-yellow :weight bold))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,spectral-green :weight bold))))
   `(c-annotation-face ((t (:inherit font-lock-constant-face))))
;;;;; man
   '(Man-overstrike ((t (:inherit font-lock-keyword-face))))
   '(Man-underline  ((t (:inherit (font-lock-string-face underline)))))

;;;;; woman
   '(woman-bold   ((t (:inherit font-lock-keyword-face))))
   '(woman-italic ((t (:inherit (font-lock-string-face italic)))))

;;;;; anzu
   `(anzu-mode-line ((t (:foreground "black" :background "#fefb00" :weight bold))))
   `(anzu-mode-line-no-match ((t (:foreground ,spectral-red :weight bold))))
   `(anzu-match-1 ((t (:foreground ,spectral-bg :background ,spectral-green))))
   `(anzu-match-2 ((t (:foreground ,spectral-bg :background ,spectral-orange))))
   `(anzu-match-3 ((t (:foreground ,spectral-bg :background ,spectral-blue))))
   `(anzu-replace-to ((t (:inherit anzu-replace-highlight :foreground ,spectral-yellow))))

;;;;; auto-complete
   `(ac-candidate-face ((t (:background ,spectral-bg+3 :foreground ,spectral-bg-2))))
   `(ac-selection-face ((t (:background ,spectral-blue-4 :foreground ,spectral-fg))))
   `(popup-tip-face ((t (:background ,spectral-yellow-2 :foreground ,spectral-bg-2))))
   `(popup-menu-mouse-face ((t (:background ,spectral-yellow-2 :foreground ,spectral-bg-2))))
   `(popup-summary-face ((t (:background ,spectral-bg+3 :foreground ,spectral-bg-2))))
   `(popup-scroll-bar-foreground-face ((t (:background ,spectral-blue-5))))
   `(popup-scroll-bar-background-face ((t (:background ,spectral-bg-1))))
   `(popup-isearch-match ((t (:background ,spectral-bg :foreground ,spectral-fg))))

;;;;; company-mode
   `(company-tooltip ((t (:foreground "black" :background "#005fff"))))
   `(company-tooltip-annotation ((t (:foreground "black" :background "#005fff"))))
   `(company-tooltip-annotation-selection ((t (:foreground "white" :background "#005fff" :underline t))))
   `(company-tooltip-selection ((t (:foreground "white" :background "#005fff" :underline t))))
   `(company-tooltip-mouse ((t (:background "orange"))))
   `(company-tooltip-common ((t (:foreground "white"))))
   `(company-tooltip-common-selection ((t (:foreground "red" :background "#005fff" :underline t))))
   `(company-scrollbar-fg ((t (:background "white"))))
   `(company-scrollbar-bg ((t (:background "#005fff"))))
   `(company-preview ((t (:foreground "white" :background "white"))))
   `(company-preview-common ((t (:foreground ,spectral-green+2 :background ,spectral-bg-1))))

 ;;;;; company-quickhelp
   `(company-quickhelp-color-background ,spectral-bg+1)
   `(company-quickhelp-color-foreground ,spectral-fg)

;;;;; context-coloring
   `(context-coloring-level-0-face ((t :foreground ,spectral-fg)))
   `(context-coloring-level-1-face ((t :foreground ,spectral-cyan)))
   `(context-coloring-level-2-face ((t :foreground ,spectral-green+4)))
   `(context-coloring-level-3-face ((t :foreground ,spectral-yellow)))
   `(context-coloring-level-4-face ((t :foreground ,spectral-orange)))
   `(context-coloring-level-5-face ((t :foreground ,spectral-magenta)))
   `(context-coloring-level-6-face ((t :foreground ,spectral-blue+1)))
   `(context-coloring-level-7-face ((t :foreground ,spectral-green+2)))
   `(context-coloring-level-8-face ((t :foreground ,spectral-yellow-2)))
   `(context-coloring-level-9-face ((t :foreground ,spectral-red+1)))

   `(diff-added          ((t (:background "#335533" :foreground ,spectral-green))))
   `(diff-changed        ((t (:background "#555511" :foreground ,spectral-yellow-1))))
   `(diff-removed        ((t (:background "#553333" :foreground ,spectral-red-2))))

   `(diff-refine-added   ((t (:foreground "white" :background "#00AF00" :italic t :underline t))))
   `(diff-refine-change  ((t (:foreground "white" :background "#FFFF00" :italic t :underline t))))
   `(diff-refine-removed ((t (:foreground "white" :background "#AF0000" :italic t :underline t))))

   `(diredp-display-msg ((t (:foreground ,spectral-blue))))
   `(diredp-compressed-file-suffix ((t (:foreground ,spectral-orange))))
   `(diredp-date-time ((t (:foreground ,spectral-magenta))))
   `(diredp-deletion ((t (:foreground ,spectral-yellow))))
   `(diredp-deletion-file-name ((t (:foreground ,spectral-red))))
   `(diredp-dir-heading ((t (:foreground ,spectral-blue :background ,spectral-bg-1))))
   `(diredp-dir-priv ((t (:foreground ,spectral-cyan))))
   `(diredp-exec-priv ((t (:foreground ,spectral-red))))
   `(diredp-executable-tag ((t (:foreground ,spectral-green+1))))
   `(diredp-file-name ((t (:foreground ,spectral-blue))))
   `(diredp-file-suffix ((t (:foreground ,spectral-green))))
   `(diredp-flag-mark ((t (:foreground ,spectral-yellow))))
   `(diredp-flag-mark-line ((t (:foreground ,spectral-orange))))
   `(diredp-ignored-file-name ((t (:foreground ,spectral-red))))
   `(diredp-link-priv ((t (:foreground ,spectral-yellow))))
   `(diredp-mode-line-flagged ((t (:foreground ,spectral-yellow))))
   `(diredp-mode-line-marked ((t (:foreground ,spectral-orange))))
   `(diredp-no-priv ((t (:foreground ,spectral-fg))))
   `(diredp-number ((t (:foreground ,spectral-green+1))))
   `(diredp-other-priv ((t (:foreground ,spectral-yellow-1))))
   `(diredp-rare-priv ((t (:foreground ,spectral-red-1))))
   `(diredp-read-priv ((t (:foreground ,spectral-green-1))))
   `(diredp-symlink ((t (:foreground ,spectral-yellow))))
   `(diredp-write-priv ((t (:foreground ,spectral-magenta))))
;;;;; dired-async
   `(dired-async-failures ((t (:foreground ,spectral-red :weight bold))))
   `(dired-async-message ((t (:foreground ,spectral-yellow :weight bold))))
   `(dired-async-mode-message ((t (:foreground ,spectral-yellow))))

   `(ediff-current-diff-A ((t (:foreground ,spectral-fg :background ,spectral-red-4))))
   `(ediff-current-diff-Ancestor ((t (:foreground ,spectral-fg :background ,spectral-red-4))))
   `(ediff-current-diff-B ((t (:foreground ,spectral-fg :background ,spectral-green-1))))
   `(ediff-current-diff-C ((t (:foreground ,spectral-fg :background ,spectral-blue-5))))
   `(ediff-even-diff-A ((t (:background ,spectral-bg+1))))
   `(ediff-even-diff-Ancestor ((t (:background ,spectral-bg+1))))
   `(ediff-even-diff-B ((t (:background ,spectral-bg+1))))
   `(ediff-even-diff-C ((t (:background ,spectral-bg+1))))
   `(ediff-fine-diff-A ((t (:foreground ,spectral-fg :background ,spectral-red-2 :weight bold))))
   `(ediff-fine-diff-Ancestor ((t (:foreground ,spectral-fg :background ,spectral-red-2 weight bold))))
   `(ediff-fine-diff-B ((t (:foreground ,spectral-fg :background ,spectral-green :weight bold))))
   `(ediff-fine-diff-C ((t (:foreground ,spectral-fg :background ,spectral-blue-3 :weight bold ))))
   `(ediff-odd-diff-A ((t (:background ,spectral-bg+2))))
   `(ediff-odd-diff-Ancestor ((t (:background ,spectral-bg+2))))
   `(ediff-odd-diff-B ((t (:background ,spectral-bg+2))))
   `(ediff-odd-diff-C ((t (:background ,spectral-bg+2))))

   `(w3m-anchor ((t (:foreground ,spectral-yellow :underline t
                                 :weight bold))))
   `(w3m-arrived-anchor ((t (:foreground ,spectral-yellow-2
                                         :underline t :weight normal))))
   `(w3m-form ((t (:foreground ,spectral-red-1 :underline t))))
   `(w3m-header-line-location-title ((t (:foreground ,spectral-yellow
                                                     :underline t :weight bold))))
   '(w3m-history-current-url ((t (:inherit match))))
   `(w3m-lnum ((t (:foreground ,spectral-green+2 :background ,spectral-bg))))
   `(w3m-lnum-match ((t (:background ,spectral-bg-1
                                     :foreground ,spectral-orange
                                     :weight bold))))
   `(w3m-lnum-minibuffer-prompt ((t (:foreground ,spectral-yellow))))

   `(flycheck-error
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-red-1) :inherit unspecified))
      (t (:foreground ,spectral-red-1 :weight bold :underline t))))
   `(flycheck-warning
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-yellow) :inherit unspecified))
      (t (:foreground ,spectral-yellow :weight bold :underline t))))
   `(flycheck-info
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-cyan) :inherit unspecified))
      (t (:foreground ,spectral-cyan :weight bold :underline t))))
   `(flycheck-fringe-error ((t (:foreground ,spectral-red-1 :weight bold))))
   `(flycheck-fringe-warning ((t (:foreground ,spectral-yellow :weight bold))))
   `(flycheck-fringe-info ((t (:foreground ,spectral-cyan :weight bold))))

   `(flymake-errline
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-red)
                   :inherit unspecified :foreground unspecified :background unspecified))
      (t (:foreground ,spectral-red-1 :weight bold :underline t))))
   `(flymake-warnline
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-orange)
                   :inherit unspecified :foreground unspecified :background unspecified))
      (t (:foreground ,spectral-orange :weight bold :underline t))))
   `(flymake-infoline
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-green)
                   :inherit unspecified :foreground unspecified :background unspecified))
      (t (:foreground ,spectral-green-1 :weight bold :underline t))))
;;;;; flyspell
   `(flyspell-duplicate
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-orange) :inherit unspecified))
      (t (:foreground ,spectral-orange :weight bold :underline t))))
   `(flyspell-incorrect
     ((((supports :underline (:style wave)))
       (:underline (:style wave :color ,spectral-red) :inherit unspecified))
      (t (:foreground ,spectral-red-1 :weight bold :underline t))))

   `(ack-separator ((t (:foreground ,spectral-fg))))
   `(ack-file ((t (:foreground ,spectral-blue))))
   `(ack-line ((t (:foreground ,spectral-yellow))))
   `(ack-match ((t (:foreground ,spectral-orange :background ,spectral-bg-1 :weight bold))))

;;;;; git-rebase
   `(git-rebase-hash ((t (:foreground, spectral-orange))))

   ;;`(selectrum-prescient-primary-highlight ((t (:foreground "black" :background "cyan" :bold t))))
   ;;`(selectrum-prescient-secondary-highlight ((t (:foreground "black" :background "cyan" :bold t))))
   `(selectrum-current-candidate ((t (:foreground ,spectral/skyblue :background ,spectral-bg-1 :bold t))))

   `(helm-header
     ((t (:foreground ,spectral-green
                      :background ,spectral-bg
                      :underline nil
                      :box nil))))
   `(helm-source-header
     ((t (:foreground "white"
                      :background "dark blue"
                      :underline t
                      :weight bold
                      ))))
   `(helm-selection ((t (:foreground "yellow" :background "grey10" :bold t))))
   `(helm-selection-line ((t (:background "white"))))
   `(helm-visible-mark ((t (:foreground ,spectral-bg :background ,spectral-yellow-2))))
   `(helm-candidate-number ((t (:foreground ,spectral-green+4 :background ,spectral-bg-1))))
   `(helm-separator ((t (:foreground "red" :background ,spectral-bg))))
   `(helm-time-zone-current ((t (:foreground ,spectral-green+2 :background ,spectral-bg))))
   `(helm-time-zone-home ((t (:foreground ,spectral-red :background ,spectral-bg))))
   `(helm-bookmark-addressbook ((t (:foreground ,spectral-orange :background ,spectral-bg))))
   `(helm-bookmark-directory ((t (:foreground nil :background nil :inherit helm-ff-directory))))
   `(helm-bookmark-file ((t (:foreground nil :background nil :inherit helm-ff-file))))
   `(helm-bookmark-gnus ((t (:foreground ,spectral-magenta :background ,spectral-bg))))
   `(helm-bookmark-info ((t (:foreground ,spectral-green+2 :background ,spectral-bg))))
   `(helm-bookmark-man ((t (:foreground ,spectral-yellow :background ,spectral-bg))))
   `(helm-bookmark-w3m ((t (:foreground ,spectral-magenta :background ,spectral-bg))))
   `(helm-buffer-not-saved ((t (:foreground ,spectral-red :background ,spectral-bg))))
   `(helm-buffer-process ((t (:foreground ,spectral-cyan :background ,spectral-bg))))
   `(helm-buffer-saved-out ((t (:foreground ,spectral-fg :background ,spectral-bg))))
   `(helm-buffer-size ((t (:foreground ,spectral-fg-1 :background ,spectral-bg))))
   `(helm-ff-directory ((t (:foreground ,spectral-cyan :background ,spectral-bg :weight bold))))
   `(helm-ff-file ((t (:foreground "white" :background "black" :weight normal))))
   `(helm-ff-executable ((t (:foreground ,spectral-green+2 :background ,spectral-bg :weight normal))))
   `(helm-ff-invalid-symlink ((t (:foreground "red" :background "black" :weight bold))))
   `(helm-ff-symlink ((t (:foreground "white" :background "black" :weight normal))))
   `(helm-ff-prefix ((t (:foreground ,spectral-bg :background ,spectral-yellow :weight normal))))
   `(helm-grep-cmd-line ((t (:foreground ,spectral-cyan :background ,spectral-bg))))
   `(helm-grep-file ((t (:foreground ,spectral-fg :background ,spectral-bg))))
   `(helm-grep-finish ((t (:foreground ,spectral-green+2 :background ,spectral-bg))))
   `(helm-grep-lineno ((t (:foreground ,spectral-fg-1 :background ,spectral-bg))))
   `(helm-grep-match ((t (:foreground nil :background nil :inherit helm-match))))
   `(helm-grep-running ((t (:foreground ,spectral-red :background ,spectral-bg))))
   `(helm-match ((t (:foreground "SkyBlue1" :background "black" :weight bold))))
   `(helm-moccur-buffer ((t (:foreground ,spectral-cyan :background ,spectral-bg))))
   `(helm-mu-contacts-address-face ((t (:foreground ,spectral-fg-1 :background ,spectral-bg))))
   `(helm-mu-contacts-name-face ((t (:foreground ,spectral-fg :background ,spectral-bg))))
;;;;; helm-swoop
   `(helm-swoop-target-line-face ((t (:foreground ,spectral-fg :background ,spectral-bg+1))))
   `(helm-swoop-target-word-face ((t (:foreground ,spectral-yellow :background ,spectral-bg+2 :weight bold))))

;;;;; lispy
   `(lispy-command-name-face ((t (:background ,spectral-bg-05 :inherit font-lock-function-name-face))))
   `(lispy-cursor-face ((t (:foreground ,spectral-bg :background ,spectral-fg))))
   `(lispy-face-hint ((t (:inherit highlight :foreground ,spectral-yellow))))

;;;;; magit
;;;;;; headings and diffs
   `(magit-item-highlight   ((t (:inherit region))))

   `(magit-section-highlight           ((t (:background "#000000")))) ;; Not sure if I like the highlight line or not
   `(magit-section-heading             ((t (:underline t :foreground ,spectral-yellow :weight bold))))
   `(magit-section-heading-selection   ((t (:foreground ,spectral-orange :weight bold))))

   ;; This is the unchanged text that provides context in a diff - so a grey is good
   `(magit-diff-context-highlight      ((t (:foreground "grey70"))))

   ;; Faces for when it does have the focus
   `(magit-diff-added-highlight ((t (:background "#005f00"))))
   `(magit-diff-removed-highlight ((t (:background "#5f0000"))))

   `(magit-diff-added ((t (:background "#005f00" :foreground "#767676"))))
   `(magit-diff-removed ((t (:background "#5f0000" :foreground "#767676"))))

   `(magit-diff-file-heading           ((t (:foreground ,spectral/limegreen-1 :bold t))))  ;; filename in the diff?
   `(magit-diff-file-heading-highlight ((t (:foregorund ,spectral/orange :bold t))))
   `(magit-diff-file-heading-selection ((t (:foreground ,spectral/salmon :bold t))))
   `(magit-diff-hunk-heading           ((t (:foreground ,spectral-bg+3 :background ,spectral-bg-1))))
   `(magit-diff-hunk-heading-highlight ((t (:foreground ,spectral/skyblue :background ,spectral-bg-1))))
   `(magit-diff-hunk-heading-selection ((t (::background ,spectral-bg+2 :foreground ,spectral-orange))))
   `(magit-diff-lines-heading          ((t (:background ,spectral-orange :foreground ,spectral-bg+2))))

   `(magit-diffstat-added   ((t (:foreground "green"))))
   `(magit-diffstat-removed ((t (:foreground "red"))))

;;;;;; popup
   `(magit-popup-heading             ((t (:foreground ,spectral-yellow  :weight bold))))
   `(magit-popup-key                 ((t (:foreground ,spectral-green-1 :weight bold))))
   `(magit-popup-argument            ((t (:foreground ,spectral-green   :weight bold))))
   `(magit-popup-disabled-argument   ((t (:foreground ,spectral-fg-1    :weight normal))))
   `(magit-popup-option-value        ((t (:foreground ,spectral-blue-2  :weight bold))))

;;;;;; process
   `(magit-process-ok    ((t (:foreground ,spectral-green  :weight bold))))
   `(magit-process-ng    ((t (:foreground ,spectral-red    :weight bold))))

;;;;;; log
   `(magit-log-author    ((t (:foreground ,spectral/light-blue))))
   `(magit-log-date      ((t (:foreground ,spectral-green))))
   `(magit-log-graph     ((t (:foreground ,spectral-fg+1))))

;;;;;; sequence
   `(magit-sequence-pick ((t (:foreground ,spectral-yellow-2))))
   `(magit-sequence-stop ((t (:foreground ,spectral-green))))
   `(magit-sequence-part ((t (:foreground ,spectral-yellow))))
   `(magit-sequence-head ((t (:foreground ,spectral-blue))))
   `(magit-sequence-drop ((t (:foreground ,spectral-red))))
   `(magit-sequence-done ((t (:foreground ,spectral-fg-1))))
   `(magit-sequence-onto ((t (:foreground ,spectral-fg-1))))

;;;;;; bisect
   `(magit-bisect-good ((t (:foreground ,spectral-green))))
   `(magit-bisect-skip ((t (:foreground ,spectral-yellow))))
   `(magit-bisect-bad  ((t (:foreground ,spectral-red))))
;;;;;; blame
   `(magit-blame-heading ((t (:background ,spectral-bg-1 :foreground ,spectral-blue-2))))
   `(magit-blame-hash    ((t (:background ,spectral-bg-1 :foreground ,spectral-blue-2))))
   `(magit-blame-name    ((t (:background ,spectral-bg-1 :foreground ,spectral-orange))))
   `(magit-blame-date    ((t (:background ,spectral-bg-1 :foreground ,spectral-orange))))
   `(magit-blame-summary ((t (:background ,spectral-bg-1 :foreground ,spectral-blue-2
                                          :weight bold))))
;;;;;; references etc
   `(magit-dimmed         ((t (:foreground ,spectral-bg+3))))
   `(magit-hash           ((t (:foreground ,spectral/lightblue-2))))

   `(magit-tag            ((t (:foreground ,spectral-blue+1 :italic t))))
   `(magit-branch-remote  ((t (:foreground "white" :background ,spectral-red-4 :underline t))))
   `(magit-branch-current ((t (:foreground "white" :background "#008700" :bold t))))
   `(magit-branch-local   ((t (:foreground "#00ff87" :underline t ))))
   `(magit-head           ((t (:foreground ,spectral-green-1 :background "black" :weight bold))))

   `(magit-refname        ((t (:background ,spectral-bg+2 :foreground ,spectral-fg :weight bold))))
   `(magit-refname-stash  ((t (:background ,spectral-bg+2 :foreground ,spectral-fg :weight bold))))
   `(magit-refname-wip    ((t (:background ,spectral-bg+2 :foreground ,spectral-fg :weight bold))))
   `(magit-signature-good      ((t (:foreground ,spectral-green))))
   `(magit-signature-bad       ((t (:foreground ,spectral-red))))
   `(magit-signature-untrusted ((t (:foreground ,spectral-yellow))))
   `(magit-signature-expired   ((t (:foreground ,spectral-red))))
   `(magit-signature-revoked   ((t (:foreground ,spectral-magenta))))
   '(magit-signature-error     ((t (:inherit    magit-signature-bad))))
   `(magit-cherry-unmatched    ((t (:foreground ,spectral-cyan))))
   `(magit-cherry-equivalent   ((t (:foreground ,spectral-magenta))))
   `(magit-reflog-commit       ((t (:foreground ,spectral-green))))
   `(magit-reflog-amend        ((t (:foreground ,spectral-magenta))))
   `(magit-reflog-merge        ((t (:foreground ,spectral-green))))
   `(magit-reflog-checkout     ((t (:foreground ,spectral-blue))))
   `(magit-reflog-reset        ((t (:foreground ,spectral-red))))
   `(magit-reflog-rebase       ((t (:foreground ,spectral-magenta))))
   `(magit-reflog-cherry-pick  ((t (:foreground ,spectral-green))))
   `(magit-reflog-remote       ((t (:foreground ,spectral-cyan))))
   `(magit-reflog-other        ((t (:foreground ,spectral-cyan))))

   `(message-cited-text ((t (:inherit font-lock-comment-face))))
   `(message-header-name ((t (:foreground ,spectral-green+1))))
   `(message-header-other ((t (:foreground ,spectral-green))))
   `(message-header-to ((t (:foreground ,spectral-yellow :weight bold))))
   `(message-header-cc ((t (:foreground ,spectral-yellow :weight bold))))
   `(message-header-newsgroups ((t (:foreground ,spectral-yellow :weight bold))))
   `(message-header-subject ((t (:foreground ,spectral-orange :weight bold))))
   `(message-header-xheader ((t (:foreground ,spectral-green))))
   `(message-mml ((t (:foreground ,spectral-yellow :weight bold))))
   `(message-separator ((t (:inherit font-lock-comment-face))))

   ;;; org mode goodies
   `(org-agenda-date-today
     ((t (:foreground ,spectral-fg+1 :slant italic :weight bold))) t)
   `(org-agenda-structure
     ((t (:inherit font-lock-comment-face))))
   `(org-archived ((t (:foreground ,spectral-fg :weight bold))))
   `(org-checkbox ((t (:background ,spectral-bg+2 :foreground ,spectral-fg+1
                                   :box (:line-width 1 :style released-button)))))
   `(org-date ((t (:foreground ,spectral-blue :underline t))))
   `(org-deadline-announce ((t (:foreground ,spectral-red-1))))
   `(org-done ((t (:weight bold :weight bold :foreground ,spectral-green+3))))
   `(org-formula ((t (:foreground ,spectral-yellow-2))))
   `(org-headline-done ((t (:foreground ,spectral-green+3))))
   `(org-hide ((t (:foreground ,spectral-bg-1))))
   `(org-link ((t (:foreground ,spectral-yellow-2 :underline t))))
   `(org-scheduled ((t (:foreground ,spectral-green+4))))
   `(org-scheduled-previously ((t (:foreground ,spectral-red))))
   `(org-scheduled-today ((t (:foreground ,spectral-blue+1))))
   `(org-sexp-date ((t (:foreground ,spectral-blue+1 :underline t))))
   `(org-special-keyword ((t (:inherit font-lock-comment-face))))
   `(org-table ((t (:foreground ,spectral-green+2))))
   `(org-tag ((t (:weight bold :weight bold))))
   `(org-time-grid ((t (:foreground ,spectral-orange))))
   `(org-todo ((t (:weight bold :foreground ,spectral-red :weight bold))))
   `(org-upcoming-deadline ((t (:inherit font-lock-keyword-face))))
   `(org-warning ((t (:weight bold :foreground ,spectral-red :weight bold :underline nil))))
   `(org-column ((t (:background ,spectral-bg-1))))
   `(org-column-title ((t (:background ,spectral-bg-1 :underline t :weight bold))))
   `(org-mode-line-clock ((t (:foreground ,spectral-fg :background ,spectral-bg-1))))
   `(org-mode-line-clock-overrun ((t (:foreground ,spectral-bg :background ,spectral-red-1))))
   `(org-ellipsis ((t (:foreground ,spectral-yellow-1 :underline t))))
   `(org-footnote ((t (:foreground ,spectral-cyan :underline t))))
   `(org-document-title ((t (:foreground ,spectral-blue))))
   `(org-document-info ((t (:foreground ,spectral-blue))))
   `(org-habit-ready-face ((t :background ,spectral-green)))
   `(org-habit-alert-face ((t :background ,spectral-yellow-1 :foreground ,spectral-bg)))
   `(org-habit-clear-face ((t :background ,spectral-blue-3)))
   `(org-habit-overdue-face ((t :background ,spectral-red-3)))
   `(org-habit-clear-future-face ((t :background ,spectral-blue-4)))
   `(org-habit-ready-future-face ((t :background ,spectral-green-1)))
   `(org-habit-alert-future-face ((t :background ,spectral-yellow-2 :foreground ,spectral-bg)))
   `(org-habit-overdue-future-face ((t :background ,spectral-red-4)))

   `(powerline-active1 ((t (:background ,spectral-bg-05 :inherit mode-line))))
   `(powerline-active2 ((t (:background ,spectral-bg+2 :inherit mode-line))))
   `(powerline-inactive1 ((t (:background ,spectral-bg+1 :inherit mode-line-inactive))))
   `(powerline-inactive2 ((t (:background ,spectral-bg+3 :inherit mode-line-inactive))))

   `(rainbow-delimiters-depth-1-face ((t (:bold t))))
   `(rainbow-delimiters-depth-2-face ((t (:bold t :foreground "#d70000" :background "#000000"))))
   `(rainbow-delimiters-depth-3-face ((t (:bold t :foreground "#ff8700" :background "#000000"))))
   `(rainbow-delimiters-depth-4-face ((t (:bold t :foreground "#ffff00" :background "#000000"))))
   `(rainbow-delimiters-depth-5-face ((t (:bold t :foreground "#00ff00" :background "#000000"))))
   `(rainbow-delimiters-depth-6-face ((t (:bold t :foreground "#00afff" :background "#000000"))))
   `(rainbow-delimiters-depth-7-face ((t (:bold t :foreground "#0000ff" :background "#000000"))))
   `(rainbow-delimiters-depth-8-face ((t (:bold t :foreground "#FF88FF" :background "#000000"))))
   `(rainbow-delimiters-unmatched-face ((t (:bold t :foreground "white" :background "#D70000"))))

;;;;; re-builder
   `(reb-match-0 ((t (:foreground ,spectral-bg :background ,spectral-magenta))))
   `(reb-match-1 ((t (:foreground ,spectral-bg :background ,spectral-blue))))
   `(reb-match-2 ((t (:foreground ,spectral-bg :background ,spectral-orange))))
   `(reb-match-3 ((t (:foreground ,spectral-bg :background ,spectral-red))))

;;;;; realgud
   `(realgud-overlay-arrow1 ((t (:foreground ,spectral-green))))
   `(realgud-overlay-arrow2 ((t (:foreground ,spectral-yellow))))
   `(realgud-overlay-arrow3 ((t (:foreground ,spectral-orange))))
   `(realgud-bp-enabled-face ((t (:inherit error))))
   `(realgud-bp-disabled-face ((t (:inherit secondary-selection))))
   `(realgud-bp-line-enabled-face ((t (:foreground ,spectral-bg :background ,spectral-red))))
   `(realgud-bp-line-disabled-face ((t (:inherit secondary-selection))))
   `(realgud-line-number ((t (:foreground ,spectral-yellow))))
   `(realgud-backtrace-number ((t (:foreground ,spectral-yellow, :weight bold))))
;;;;; regex-tool
   `(regex-tool-matched-face ((t (:background ,spectral-blue-4 :weight bold))))

   `(rpm-spec-dir-face ((t (:foreground ,spectral-green))))
   `(rpm-spec-doc-face ((t (:foreground ,spectral-green))))
   `(rpm-spec-ghost-face ((t (:foreground ,spectral-red))))
   `(rpm-spec-macro-face ((t (:foreground ,spectral-yellow))))
   `(rpm-spec-obsolete-tag-face ((t (:foreground ,spectral-red))))
   `(rpm-spec-package-face ((t (:foreground ,spectral-red))))
   `(rpm-spec-section-face ((t (:foreground ,spectral-yellow))))
   `(rpm-spec-tag-face ((t (:foreground ,spectral-blue))))
   `(rpm-spec-var-face ((t (:foreground ,spectral-red))))

   `(show-paren-mismatch ((t (:foreground "white" :background "#D70000" :weight bold))))
   `(show-paren-match ((t (:underline t :inverse-video t :weight bold))))
   `(show-paren-match-expression ((t (:italic t :bold t))))

;;;;; smartparens -- Doesn't seem used
   ;;`(sp-show-pair-mismatch-face ((t (:foreground "#ff0000" :background "white" :weight bold))))
   ;;`(sp-show-pair-match-face ((t (:background "white" :background "#ff0000" :weight bold))))

;;;;; sml-mode-line
   '(sml-modeline-end-face ((t :inherit default :width condensed)))

   `(speedbar-button-face ((t (:foreground ,spectral-green+2))))
   `(speedbar-directory-face ((t (:foreground ,spectral-cyan))))
   `(speedbar-file-face ((t (:foreground ,spectral-fg))))
   `(speedbar-highlight-face ((t (:foreground ,spectral-bg :background ,spectral-green+2))))
   `(speedbar-selected-face ((t (:foreground ,spectral-red))))
   `(speedbar-separator-face ((t (:foreground ,spectral-bg :background ,spectral-blue-1))))
   `(speedbar-tag-face ((t (:foreground ,spectral-yellow))))

   `(undo-tree-visualizer-active-branch-face ((t (:foreground ,spectral-fg+1 :weight bold))))
   `(undo-tree-visualizer-current-face ((t (:foreground ,spectral-red-1 :weight bold))))
   `(undo-tree-visualizer-default-face ((t (:foreground ,spectral-fg))))
   `(undo-tree-visualizer-register-face ((t (:foreground ,spectral-yellow))))
   `(undo-tree-visualizer-unmodified-face ((t (:foreground ,spectral-cyan))))

;;;;; web-mode
   `(web-mode-builtin-face ((t (:inherit ,font-lock-builtin-face))))
   `(web-mode-comment-face ((t (:inherit ,font-lock-comment-face))))
   `(web-mode-constant-face ((t (:inherit ,font-lock-constant-face))))
   `(web-mode-css-at-rule-face ((t (:foreground ,spectral-orange ))))
   `(web-mode-css-prop-face ((t (:foreground ,spectral-orange))))
   `(web-mode-css-pseudo-class-face ((t (:foreground ,spectral-green+3 :weight bold))))
   `(web-mode-css-rule-face ((t (:foreground ,spectral-blue))))
   `(web-mode-doctype-face ((t (:inherit ,font-lock-comment-face))))
   `(web-mode-folded-face ((t (:underline t))))
   `(web-mode-function-name-face ((t (:foreground ,spectral-blue))))
   `(web-mode-html-attr-name-face ((t (:foreground ,spectral-orange))))
   `(web-mode-html-attr-value-face ((t (:inherit ,font-lock-string-face))))
   `(web-mode-html-tag-face ((t (:foreground ,spectral-cyan))))
   `(web-mode-keyword-face ((t (:inherit ,font-lock-keyword-face))))
   `(web-mode-preprocessor-face ((t (:inherit ,font-lock-preprocessor-face))))
   `(web-mode-string-face ((t (:inherit ,font-lock-string-face))))
   `(web-mode-type-face ((t (:inherit ,font-lock-type-face))))
   `(web-mode-variable-name-face ((t (:inherit ,font-lock-variable-name-face))))
   `(web-mode-server-background-face ((t (:background ,spectral-bg))))
   `(web-mode-server-comment-face ((t (:inherit web-mode-comment-face))))
   `(web-mode-server-string-face ((t (:inherit web-mode-string-face))))
   `(web-mode-symbol-face ((t (:inherit font-lock-constant-face))))
   `(web-mode-warning-face ((t (:inherit font-lock-warning-face))))
   `(web-mode-whitespaces-face ((t (:background ,spectral-red))))
;;;;; whitespace-mode
   `(whitespace-space ((t (:background ,spectral-bg+1 :foreground ,spectral-bg+1))))
   `(whitespace-hspace ((t (:background ,spectral-bg+1 :foreground ,spectral-bg+1))))
   `(whitespace-tab ((t (:background ,spectral-red-1))))
   `(whitespace-newline ((t (:foreground ,spectral-bg+1))))
   `(whitespace-trailing ((t (:background ,spectral-red))))
   `(whitespace-line ((t (:background ,spectral-bg :foreground ,spectral-magenta))))
   `(whitespace-space-before-tab ((t (:background ,spectral-orange :foreground ,spectral-orange))))
   `(whitespace-indentation ((t (:background ,spectral-yellow :foreground ,spectral-red))))
   `(whitespace-empty ((t (:background ,spectral-yellow))))
   `(whitespace-space-after-tab ((t (:background ,spectral-yellow :foreground ,spectral-red))))
   `(which-func ((t (:foreground "#eea0ee"))))
   `(underline                    ((nil (:underline nil)))))

  (custom-theme-set-variables
   'spectral
   `(spectral/powerline-glyph-before-filename
     '(""
       (:propertize " " face powerline-active1)
       (:eval (propertize " " 'display (funcall ,separator-left 'powerline-active1 'powerline-active1)))
       (:propertize " " face sml/global)))))

(provide-theme 'spectral)
;;; spectral-theme.el ends here
