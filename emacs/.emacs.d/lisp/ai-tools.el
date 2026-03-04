;;; ai-tools.el --- AI-powered coding assistants -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Copilot, gptel, agent-shell, and related AI tooling.
;; All use-package blocks are copied verbatim from the original init.el.

;;; Code:

;; Ensure Emacs has the same PATH you'd use in a terminal
(dolist (path '("/usr/local/bin"))
  (add-to-list 'exec-path path)
  (unless (string-match-p (regexp-quote path) (or (getenv "PATH") ""))
    (setenv "PATH" (concat path ":" (or (getenv "PATH") "")))))

(use-package gptel
  :config
  (setq gptel-model 'claude-sonnet-4-5-20250929)
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :key (getenv "CLAUDE_API_KEY")
          :models '(claude-sonnet-4-5-20250929))))

(use-package shell-maker)

(use-package acp)

(use-package agent-shell)

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
  (eej/copilot-chat-enable)

  (defun eej/copilot-chat-set-default-model ()
    "Set copilot-chat model to claude-opus-4.6 once."

    (message "Setting copilot-chat model to claude-opus-4.6")
    (copilot-chat-set-model "claude-opus-4.6"))

  (add-hook 'copilot-chat-org-prompt-mode-hook
            #'eej/copilot-chat-set-default-model))

(with-eval-after-load 'agent-shell
  (defun eej/agent-shell-transcript-path ()
    "Store agent-shell transcripts under ~/.cache/agent-shell/transcripts/."
    (let* ((base (expand-file-name "~/org/agent-shell/transcripts/"))
           (project (file-name-nondirectory (directory-file-name (agent-shell-cwd))))
           (dir (expand-file-name project base))
           (file (format-time-string "%F-%H-%M-%S.md")))
      (expand-file-name file dir)))

  (setopt agent-shell-transcript-file-path-function #'eej/agent-shell-transcript-path))

(provide 'ai-tools)
;;; ai-tools.el ends here
