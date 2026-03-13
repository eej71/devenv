;;; power-user-tools.el --- Advanced productivity packages -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Power user tools for enhanced productivity, navigation, and editing.
;; Optimized for terminal mode usage.

;;; Code:

;; ── Wgrep - Make grep/ripgrep buffers editable ─────────────────────────
;; USAGE: After running consult-ripgrep (C-c s r), press C-c C-p in the results
;;        to enter edit mode. Make changes directly in the buffer, then C-c C-c
;;        to apply changes to all files, or C-c C-k to abort.
;;        Perfect for project-wide refactoring!
(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t          ; Auto-save files after editing
        wgrep-change-readonly-file t))     ; Allow editing read-only files

;; ── Avy - Jump to any visible character with 2-3 keystrokes ───────────
;; USAGE: This is like vim's easymotion or tmux's jump mode.
;;        
;;        C-c j j (avy-goto-char-timer): Type 1-2 chars you want to jump to. Avy shows
;;            letters next to each match. Type the letter to jump there instantly.
;;            Example: Press C-c j j, type "de", see letters appear, type "j" to jump.
;;        
;;        C-c j w (avy-goto-word-1): Type first letter of a word. Jump to any word
;;            starting with that letter.
;;        
;;        C-c j l (avy-goto-line): Jump to any visible line.
;;        
;;        M-g w (avy-goto-word-0): Jump to beginning of any visible word (no input).
;;        
;;        Works across all visible windows! No more repeatedly pressing C-s or
;;        holding down C-n/C-p. This will transform how you navigate in Emacs.
;;
;;        Pro tip: In a split window layout, you can jump between windows instantly
;;        by targeting text in the other window.
;;
;;        Note: Using C-c j prefix instead of C-' because C-' doesn't work reliably
;;        in terminal mode (terminals can't distinguish it from plain ').
(use-package avy
  :init
  ;; Create a prefix keymap for avy commands
  (define-prefix-command 'eej-avy-map)
  (global-set-key (kbd "C-c j") 'eej-avy-map)
  
  :bind
  (("C-c j j" . avy-goto-char-timer)  ; Jump to char (most useful) - terminal friendly!
   ("C-c j w" . avy-goto-word-1)      ; Jump to word by first letter
   ("C-c j l" . avy-goto-line)        ; Jump to line
   ("C-c j c" . avy-goto-char)        ; Jump to char (single char, no timer)
   ("M-g w" . avy-goto-word-0))       ; Jump to any word (M-g w is safe in terminal)
  :custom
  (avy-timeout-seconds 0.3)           ; How long to wait for second char
  (avy-style 'at-full)                ; Show hints at the target location
  (avy-keys '(?a ?s ?d ?f ?j ?k ?l ?g ?h)) ; Home row keys for hints
  (avy-background t))                 ; Dim background during jump

;; ── Expand Region - Intelligently expand selection ────────────────────
;; USAGE: Place cursor inside a word, string, or expression, then press C-c e
;;        repeatedly to expand selection by semantic units.
;;        
;;        Example in code:
;;          1st C-c e: select word
;;          2nd C-c e: select string/symbol
;;          3rd C-c e: select inside parentheses
;;          4th C-c e: select including parentheses
;;          5th C-c e: select whole statement/function
;;        
;;        C-c C-e to contract selection.
;;        
;;        Much faster than manually marking regions!
;;        
;;        Note: Using C-c e instead of C-= because C-= can be problematic
;;        in some terminal emulators.
(use-package expand-region
  :bind
  (("C-c e" . er/expand-region)       ; Expand selection - terminal friendly!
   ("C-c E" . er/contract-region)))   ; Contract selection (capital E)

;; ── Multiple Cursors - Edit multiple locations simultaneously ─────────
;; USAGE: Mark a region, then C-c m c to get cursor at each line.
;;        Or C-c m e to edit all occurrences of selected text.
;;        Type normally and all cursors update together.
;;        Press C-g to exit multiple cursor mode.
;;        
;;        C-c m l: Add cursor to next line
;;        C-c m a: Add cursor based on same text
;;        
;;        Great for editing lists, similar variable names, etc.
(use-package multiple-cursors
  :bind
  (("C-c m c" . mc/edit-lines)              ; Cursor on each line in region
   ("C-c m e" . mc/mark-all-like-this)      ; All occurrences in buffer
   ("C-c m n" . mc/mark-next-like-this)     ; Add cursor to next occurrence
   ("C-c m p" . mc/mark-previous-like-this) ; Add cursor to previous
   ("C-c m a" . mc/mark-all-dwim)))         ; Smart mark all

;; ── Undo Tree - Visualize undo history as a tree ──────────────────────
;; USAGE: Undo/redo works normally with C-/ and C-? (or C-_)
;;        But now you can press C-x u to open the undo tree visualizer.
;;        
;;        In the visualizer:
;;          - Use n/p or arrow keys to navigate through undo states
;;          - See a tree structure showing branches where you made different edits
;;          - Press q to quit and return to the buffer at that state
;;          - Press d to toggle diff view showing what changed
;;        
;;        This saves you from losing work when you undo too far then make new edits.
;;        History is saved between sessions in ~/tmp/undo-tree/
(use-package undo-tree
  :config
  (global-undo-tree-mode)
  :custom
  (undo-tree-auto-save-history nil)                         ; Disabled — serializing large undo trees causes minute-long save stalls
  (undo-tree-history-directory-alist '(("." . "~/tmp/undo-tree")))
  (undo-tree-visualizer-diff t)                            ; Show diff in visualizer
  (undo-tree-visualizer-timestamps t))                     ; Show timestamps

(defun eej/undo-tree-disable-history-for-bookmarks-file ()
  "Disable persistent undo-tree history when visiting the bookmarks file."
  (when (and (bound-and-true-p undo-tree-mode)
             buffer-file-name
             (string= (file-truename buffer-file-name)
                      (file-truename
                       (expand-file-name
                        (if (boundp 'bookmark-default-file)
                            bookmark-default-file
                          (locate-user-emacs-file "bookmarks"))))))
    (setq-local undo-tree-auto-save-history nil)))

(add-hook 'find-file-hook #'eej/undo-tree-disable-history-for-bookmarks-file)

;; ── Diff-hl - Show git diff indicators in the margin ──────────────────
;; USAGE: Automatically shows indicators in the left margin for:
;;          + Green: Added lines
;;          ~ Blue: Modified lines  
;;          - Red: Deleted lines
;;        
;;        In a diff-hl indicator, use:
;;          C-x v n: Jump to next change
;;          C-x v p: Jump to previous change
;;          C-x v r: Revert this hunk
;;          C-x v =: Show the diff for this hunk
;;        
;;        Works great in terminal mode! Auto-refreshes after magit operations.
(use-package diff-hl
  :hook
  ((prog-mode . diff-hl-mode)           ; Enable in programming modes
   (dired-mode . diff-hl-dired-mode)    ; Show git status in dired
   (magit-pre-refresh . diff-hl-magit-pre-refresh)
   (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  ;; Use margin instead of fringe in terminal mode
  (unless (display-graphic-p)
    (diff-hl-margin-mode))
  :custom
  (diff-hl-draw-borders nil))           ; Cleaner look

;; ── Helpful - Better *help* buffers ───────────────────────────────────
;; USAGE: Replaces standard help commands with enhanced versions.
;;        Press C-h f (describe-function), C-h v (describe-variable), etc.
;;        as usual, but now you get:
;;          - Source code shown inline with syntax highlighting
;;          - All references to the symbol
;;          - Better formatting and navigation
;;          - Clickable buttons to jump to definition
;;        
;;        In a helpful buffer, press TAB to move between buttons.
(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)   ; C-h f
  ([remap describe-variable] . helpful-variable)   ; C-h v
  ([remap describe-key] . helpful-key)             ; C-h k
  ([remap describe-command] . helpful-command)     ; C-h x
  ([remap describe-symbol] . helpful-symbol))      ; C-h o

;; ── Symbol Overlay - Highlight symbol at point ────────────────────────
;; USAGE: In a programming buffer, place cursor on a variable/function name
;;        and press M-i to highlight all occurrences in the buffer.
;;        
;;        M-i: Toggle highlighting for symbol at point
;;        M-n: Jump to next occurrence
;;        M-p: Jump to previous occurrence
;;        M-I: Remove all highlights
;;        
;;        Different symbols get different colors (up to 7 colors).
;;        Great for understanding code flow and finding all uses of a variable.
(use-package symbol-overlay
  :hook (prog-mode . symbol-overlay-mode)
  :bind (:map symbol-overlay-mode-map
         ("M-i" . symbol-overlay-put)         ; Highlight/unhighlight symbol
         ("M-I" . symbol-overlay-remove-all)  ; Clear all highlights
         ("M-n" . symbol-overlay-jump-next)   ; Next occurrence
         ("M-p" . symbol-overlay-jump-prev))  ; Previous occurrence
  :custom
  (symbol-overlay-idle-time 0.1))           ; How quickly to highlight

;; ── Dired Subtree - Inline subdirectories in dired ────────────────────
;; USAGE: In dired, place cursor on a directory and press 'i' to expand it
;;        inline (instead of opening in a new buffer). Press 'i' again to collapse.
;;        
;;        This lets you see deep directory trees in a single dired buffer.
;;        Combined with dired-hide-details-mode (toggle with '('), you get
;;        a nice tree-like view similar to ranger or nnn.
;;        
;;        Also binds ';' to remove subtree at point.
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
         ("i" . dired-subtree-toggle)    ; Toggle subtree expansion
         (";" . dired-subtree-remove)))  ; Remove subtree

;; ── Enhanced Dired Settings ───────────────────────────────────────────
;; USAGE: Dired enhancements that work well with terminal mode:
;;        - When two dired buffers are visible, operations suggest the other as target
;;        - Auto-refresh when files change
;;        - Human-readable file sizes
(use-package dired
  :straight nil
  :custom
  (dired-dwim-target t)                    ; Suggest other dired buffer as copy/move target
  (dired-recursive-copies 'always)         ; Don't ask about recursive copies
  (dired-recursive-deletes 'always)        ; Don't ask about recursive deletes
  (dired-listing-switches "-alh")          ; Human-readable sizes
  (dired-kill-when-opening-new-dired-buffer t) ; Keep only one dired buffer
  :config
  ;; Auto-refresh dired buffers when files change
  (setq global-auto-revert-non-file-buffers t)
  (setq auto-revert-verbose nil))

;; ── Better Ansi Colors in Compilation ─────────────────────────────────
;; USAGE: Automatic - compilation buffers now properly display ANSI color codes
;;        from build tools, test runners, etc. No more garbage [32m sequences!
(use-package ansi-color
  :straight nil
  :hook (compilation-filter . ansi-color-compilation-filter))

(setq compilation-scroll-output 'first-error  ; Auto-scroll to first error
      compilation-always-kill t)               ; Don't ask about killing old compilation

;; ── Additional Productivity Settings ──────────────────────────────────
;; Better bookmarks
(setq bookmark-save-flag 1)  ; Save bookmarks after every change

;; Enable repeat mode (Emacs 28+) for easier repeated commands
;; After using C-x o to switch windows, you can just press 'o' repeatedly
(when (fboundp 'repeat-mode)
  (repeat-mode 1))

;; Faster screen updates in terminal
(setq fast-but-imprecise-scrolling t)

;; Better clipboard integration
(setq select-enable-clipboard t
      select-enable-primary t)

;; Mouse support in terminal (for when you need it)
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
  (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

(provide 'power-user-tools)
;;; power-user-tools.el ends here
