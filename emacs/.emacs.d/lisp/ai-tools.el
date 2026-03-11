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

;; Node.js uses compiled-in certs that don't include corporate CA certs.
;; Point it at the system bundle so SSL inspection doesn't break copilot.el.
(unless (getenv "NODE_EXTRA_CA_CERTS")
  (let ((bundle (seq-find #'file-exists-p
                          '("/etc/pki/tls/certs/ca-bundle.crt"      ; Fedora/RHEL
                            "/etc/ssl/certs/ca-certificates.crt"    ; Debian/Ubuntu
                            "/etc/ssl/ca-bundle.pem"                ; openSUSE
                            "/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem")))) ; newer RHEL
    (if bundle
        (setenv "NODE_EXTRA_CA_CERTS" bundle)
      (message "ai-tools: WARNING: no system CA bundle found for NODE_EXTRA_CA_CERTS"))))

(defun eej/project-root-or-default ()
  "Return current project root or `default-directory' when outside a project."
  (require 'project)
  (if-let ((project (project-current nil (file-truename default-directory))))
      (project-root project)
    (expand-file-name default-directory)))

(defun eej/project-agent-shell-buffer (identifier)
  "Return this project's `agent-shell' buffer matching IDENTIFIER, or nil."
  (let ((buffers (agent-shell-project-buffers))
        found)
    (while (and buffers (not found))
      (let ((buffer (car buffers)))
        (when (eq identifier (alist-get :identifier (agent-shell-get-config buffer)))
          (setq found buffer)))
      (setq buffers (cdr buffers)))
    found))

(defun eej/anthropic-logged-in-p ()
  "Return non-nil if `claude auth status' reports an active login."
  (string-match-p "\"loggedIn\":\\s-*true"
                  (condition-case nil
                      (shell-command-to-string "claude auth status")
                    (error ""))))

(message "ai-tools: EEJ_PROFILE=%s" (or (getenv "EEJ_PROFILE") "(unset)"))

(defun eej/anthropic-authentication ()
  "Return Anthropic auth config for agent-shell.
Tries :login if `claude auth status' reports logged in, otherwise
falls back to :api-key using CLAUDE_API_KEY."
  (if (eej/anthropic-logged-in-p)
      (agent-shell-anthropic-make-authentication :login t)
    (agent-shell-anthropic-make-authentication
     :api-key (lambda ()
                (or (getenv "CLAUDE_API_KEY")
                    (error "Not logged in to claude.ai and CLAUDE_API_KEY is unset"))))))

(defun eej/make-agent-config ()
  "Return the agent-shell config appropriate for the current EEJ_PROFILE.
Work profile uses GitHub Copilot.  All other profiles use Anthropic
Claude Code, preferring subscription login and falling back to
CLAUDE_API_KEY if not logged in."
  (if (string-equal (getenv "EEJ_PROFILE") "Work")
      (agent-shell-github-make-copilot-config)
    (setq agent-shell-anthropic-authentication (eej/anthropic-authentication))
    (agent-shell-anthropic-make-claude-code-config)))

(defun eej/project-agent-shell ()
  "Switch to this project's agent shell, creating it if needed."
  (interactive)
  (require 'agent-shell)
  (let* ((default-directory (eej/project-root-or-default))
         (config (eej/make-agent-config))
         (id (alist-get :identifier config)))
    (if-let ((existing (eej/project-agent-shell-buffer id)))
        (agent-shell--display-buffer existing)
      (agent-shell-start :config config))))

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

(define-prefix-command 'eej-ai-map)
(global-set-key (kbd "C-c i") 'eej-ai-map)
(define-key eej-ai-map (kbd "a") #'eej/project-agent-shell)
(define-key eej-ai-map (kbd "c") #'eej/project-copilot-chat)
(define-key eej-ai-map (kbd "g") #'gptel)
(define-key eej-ai-map (kbd "l") #'claude-code-ide)
(define-key eej-ai-map (kbd "b") #'claude-code-ide-switch-to-buffer)
(define-key eej-ai-map (kbd "x") #'eej/start-codex)

(with-eval-after-load 'project
  (define-key project-prefix-map (kbd "a") #'eej/project-agent-shell)
  (define-key project-prefix-map (kbd "h") #'eej/project-copilot-chat)
  (define-key project-prefix-map (kbd "l") #'claude-code-ide))

(use-package gptel
  :config
  (setq gptel-model 'claude-opus-4-6)
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :key (getenv "CLAUDE_API_KEY")
          :stream t
          :models '(claude-opus-4-6)
          :request-params '(:thinking (:type "enabled" :budget_tokens 16000)
                            :max_tokens 32000)))

  ;; Use org-mode for gptel buffers so responses get proper markup,
  ;; code blocks, and heading-based visual separation.
  (setq gptel-default-mode 'org-mode)

  ;; Org headings label who said what.
  (setq gptel-prompt-prefix-alist
        '((org-mode . "* You\n")))
  (setq gptel-response-prefix-alist
        '((org-mode . "* Claude\n")))

  ;; Highlight the full response region with a face so it's
  ;; immediately visually distinct from the prompt.
  (setq gptel-highlight-methods '(face))
  (set-face-attribute 'gptel-response-highlight nil
                      :background "#1a2f1a" :extend t))

(use-package shell-maker)

(use-package acp)

(use-package agent-shell
  :custom
  (agent-shell-github-default-model-id "claude-opus-4.6")
  (agent-shell-anthropic-default-model-id "claude-opus-4.6")
  :config
  (setq agent-shell-preferred-agent-config
        (if (string-equal (getenv "EEJ_PROFILE") "Work") 'copilot 'claude-code))
  (message "agent-shell: preferred config -> %s" agent-shell-preferred-agent-config)
  (defun eej/agent-shell-transcript-path ()
    "Store agent-shell transcripts under ~/org/agent-shell/transcripts/."
    (let* ((base (expand-file-name "~/org/agent-shell/transcripts/"))
           (project (file-name-nondirectory (directory-file-name (agent-shell-cwd))))
           (dir (expand-file-name project base))
           (file (format-time-string "%F-%H-%M-%S.md")))
      (expand-file-name file dir)))
  (setopt agent-shell-transcript-file-path-function #'eej/agent-shell-transcript-path))

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

  :hook (prog-mode . eej/maybe-copilot-mode)

  :config
  (defun eej/maybe-copilot-mode ()
    "Enable `copilot-mode' only when the language server is available."
    (condition-case nil
        (when (copilot-server-executable)
          (copilot-mode 1))
      (error nil)))
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

(use-package claude-code-ide
  :straight (claude-code-ide :type git :host github :repo "manzaltu/claude-code-ide.el")
  :custom
  (claude-code-ide-cli-extra-flags "--model claude-opus-4-6 -c model_reasoning_effort=high")
  (claude-code-ide-window-side 'left)
  (claude-code-ide-window-width 110)
  :config
  (if (string-equal (getenv "EEJ_PROFILE") "Work")
      (message "claude-code-ide: Work profile — using claude CLI as-is")
    ;; Home: prefer Pro plan login; fall back to CLAUDE_API_KEY if not logged in.
    (if (eej/anthropic-logged-in-p)
        (message "claude-code-ide: Home profile — using Pro plan login")
      (if-let ((key (getenv "CLAUDE_API_KEY")))
          (progn
            (setenv "ANTHROPIC_API_KEY" key)
            (message "claude-code-ide: Home profile — Pro login not found, using CLAUDE_API_KEY"))
        (message "claude-code-ide: Home profile — WARNING: not logged in and CLAUDE_API_KEY is unset"))))
  (defun eej/claude-code-send-return ()
    "Submit input to the Claude Code terminal process."
    (interactive)
    (claude-code-ide--terminal-send-return))
  (advice-add 'claude-code-ide--setup-terminal-keybindings :after
              (lambda ()
                (local-set-key (kbd "RET") #'claude-code-ide-insert-newline)
                (local-set-key (kbd "C-c RET") #'eej/claude-code-send-return)
                (local-set-key (kbd "C-c C-c") #'eej/claude-code-send-return))))

(provide 'ai-tools)
;;; ai-tools.el ends here
