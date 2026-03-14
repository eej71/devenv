;;; ai-tools.el --- AI-powered coding assistants -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Copilot, gptel, and related AI tooling.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

;; Ensure Emacs has the same PATH you'd use in a terminal
(dolist (path '("/usr/local/bin"))
  (add-to-list 'exec-path path)
  (unless (string-match-p (regexp-quote path) (or (getenv "PATH") ""))
    (setenv "PATH" (concat path ":" (or (getenv "PATH") "")))))

;; Node.js uses compiled-in certs that don't include corporate CA certs.
;; Point it at the system bundle so SSL inspection doesn't break copilot.el.
(unless (getenv "NODE_EXTRA_CA_CERTS")
  (setenv "NODE_EXTRA_CA_CERTS" "/etc/pki/tls/certs/ca-bundle.crt"))

(defun eej/project-root-or-default ()
  "Return current project root or `default-directory' when outside a project."
  (require 'project)
  (if-let ((project (project-current nil (file-truename default-directory))))
      (project-root project)
    (expand-file-name default-directory)))

(define-prefix-command 'eej-ai-map)
(global-set-key (kbd "C-c i") 'eej-ai-map)
(define-key eej-ai-map (kbd "g") #'gptel)
(define-key eej-ai-map (kbd "l") #'claude-code-ide)
(define-key eej-ai-map (kbd "b") #'claude-code-ide-switch-to-buffer)
(define-key eej-ai-map (kbd "x") #'eej/start-codex)

(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "l") #'claude-code-ide)
  (define-key project-prefix-map (kbd "j") #'eej/project-switch-full))

(use-package gptel
  :config
  (setq gptel-model 'claude-sonnet-4-5-20250929)
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :key (getenv "CLAUDE_API_KEY")
          :models '(claude-sonnet-4-5-20250929))))

;; GitHub Copilot (completion + chat) — only configure when available
(if (locate-library "copilot")
    (progn
      (defun eej/copilot-chat--project-instance (directory)
        "Return Copilot Chat instance for DIRECTORY, creating one when needed."
        (require 'copilot-chat)
        (let* ((dir (file-name-as-directory (expand-file-name directory)))
               (instances (bound-and-true-p copilot-chat--instances))
               (existing
                (catch 'match
                  (dolist (instance instances)
                    (when (string-equal
                           (file-name-as-directory
                            (expand-file-name (copilot-chat-directory instance)))
                           dir)
                      (throw 'match instance))))))
          (or existing
              (let ((instance (copilot-chat--create dir)))
                (push instance copilot-chat--instances)
                instance))))

      (defun eej/project-copilot-chat ()
        "Switch to this project's Copilot Chat buffer, creating it if needed."
        (interactive)
        (let* ((default-directory (eej/project-root-or-default))
               (instance (eej/copilot-chat--project-instance default-directory)))
          (copilot-chat--display instance)
          (copilot-chat-goto-input)))

      (define-key eej-ai-map (kbd "c") #'eej/project-copilot-chat)
      (with-eval-after-load 'project
        (define-key project-prefix-map (kbd "h") #'eej/project-copilot-chat))

      (use-package copilot
        :straight (:host github :repo "copilot-emacs/copilot.el")
        :bind (:map copilot-mode-map
               ("M-/" . copilot-complete)
               :map copilot-completion-map
               ("TAB" . eej-copilot-tab-or-indent)
               ("<tab>" . eej-copilot-tab-or-indent)
               ("C-g" . copilot-clear-overlay)
               ("M-n" . copilot-next-completion)
               ("M-p" . copilot-previous-completion)
               ("M-f" . copilot-accept-completion-by-word)
               ("M-e" . copilot-accept-completion-by-line))

        :hook (prog-mode . copilot-mode)

        :config
        ;; Map major-mode (symbol) -> Copilot language id (string)
        (add-to-list 'copilot-major-mode-alist '(c++-ts-mode . "cpp"))
        (add-to-list 'copilot-major-mode-alist '(c-ts-mode   . "c"))
        (setq copilot-model "claude-opus-4.6")
        (setq copilot-indent-offset-warning-disable t))

      (use-package copilot-chat
        :demand t
        :config
        (setq copilot-chat-default-model "claude-opus-4.6")
        (eej/copilot-chat-enable))

      (message "ai-tools: GitHub Copilot configured"))
  (message "ai-tools: GitHub Copilot not available, skipping"))

(use-package claude-code-ide
  :straight (claude-code-ide :type git :host github :repo "manzaltu/claude-code-ide.el")
  :custom
  (claude-code-ide-cli-extra-flags "--model claude-opus-4-6 --effort high")
  (claude-code-ide-window-side 'left)
  (claude-code-ide-window-width 130)
  :config
  (defun eej/claude-code-send-return ()
    "Submit input to the Claude Code terminal process."
    (interactive)
    (claude-code-ide--terminal-send-return))
  (advice-add 'claude-code-ide--setup-terminal-keybindings :after
              (lambda ()
                (local-set-key (kbd "RET") #'claude-code-ide-insert-newline)
                (local-set-key (kbd "C-c RET") #'eej/claude-code-send-return)
                (local-set-key (kbd "C-c C-c") #'eej/claude-code-send-return)))
)

;; Minuet — inline code completion via Claude API
(if (getenv "CLAUDE_API_KEY")
    (progn
      (use-package minuet
        :straight (:host github :repo "milanglacier/minuet-ai.el")
        :hook (prog-mode . minuet-auto-suggestion-mode)
        :bind (:map minuet-active-mode-map
               ("M-/" . minuet-show-suggestion)
               ("TAB" . minuet-accept-suggestion)
               ("<tab>" . minuet-accept-suggestion)
               ("C-g" . minuet-dismiss-suggestion)
               ("M-n" . minuet-next-suggestion)
               ("M-p" . minuet-previous-suggestion)
               ("M-e" . minuet-accept-suggestion-line))
        :config
        (setq minuet-provider 'claude)
        (plist-put minuet-claude-options :api-key "CLAUDE_API_KEY")
        (plist-put minuet-claude-options :model "claude-sonnet-4-5-20250929"))
      (message "ai-tools: Minuet inline completion configured (Claude)"))
  (message "ai-tools: CLAUDE_API_KEY not set, skipping Minuet inline completion"))

(provide 'ai-tools)
;;; ai-tools.el ends here
