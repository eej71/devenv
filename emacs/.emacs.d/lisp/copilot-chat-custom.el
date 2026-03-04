;;; copilot-chat-custom.el --- Copilot Chat extensions -*- lexical-binding: t; -*-
;;
;;; Commentary:
;; Extensions and persistence helpers for Copilot Chat.
;;
;;; Code:

(require 'subr-x)
(autoload 'org-id-new "org-id")

(defcustom eej/copilot-chat-save-directory "~/org/chats/"
  "Directory where Copilot chat buffer snapshots are stored."
  :type 'directory
  :group 'applications)

(defcustom eej/copilot-chat-save-interval 600
  "Seconds between automatic snapshots for Copilot chat buffers."
  :type 'integer
  :group 'applications)

(defvar eej/copilot-chat-save-timer nil
  "Timer for periodic Copilot chat auto-save.")

(defun eej/start-codex ()
  "Open Codex CLI in ~/fubar (empty dir)."
  (interactive)
  (require 'vterm)
  (let* ((root (expand-file-name "~/fubar"))
         (buf (get-buffer-create "*codex*")))
    (with-current-buffer buf
      (setq default-directory root)
      (unless (derived-mode-p 'vterm-mode)
        (vterm-mode))
      (vterm-send-string (concat "cd " (shell-quote-argument root) "\n")))
    (pop-to-buffer buf)
    (vterm-send-string "codex\n")))

(defun eej-copilot-tab-or-indent ()
  "Accept Copilot completion if visible, otherwise indent."
  (interactive)
  (if (copilot--overlay-visible)
      (copilot-accept-completion)
    (indent-for-tab-command)))

(defun eej/copilot-chat--get-property (prop)
  "Extract a #+PROPERTY: PROP value from the current buffer."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward
           (concat "^#\\+PROPERTY:\\s-+" (regexp-quote prop) "\\s-+\\(.+\\)$")
           nil t)
      (string-trim (match-string 1)))))

(defun eej/copilot-chat--get-date ()
  "Extract the #+DATE value from the current buffer."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^#\\+DATE:\\s-+\\[\\([^]]+\\)\\]" nil t)
      (string-trim (match-string 1)))))

(defun eej/copilot-chat--compute-filename ()
  "Compute a unique filename for the current Copilot chat buffer."
  (let* ((session-dir (eej/copilot-chat--get-property "SESSION_DIR"))
         (date-str (eej/copilot-chat--get-date))
         (save-dir (expand-file-name eej/copilot-chat-save-directory)))
    (when (and session-dir date-str)
      (let* ((dir-part (replace-regexp-in-string "/" "_" session-dir))
             (dir-part (replace-regexp-in-string "\\`_+" "" dir-part))
             (dir-part (replace-regexp-in-string "_+\\'" "" dir-part))
             (date-part (when (string-match
                               "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)\\s-+[A-Za-z]+\\s-+\\([0-9]\\{2\\}\\):\\([0-9]\\{2\\}\\)"
                               date-str)
                          (concat (match-string 1 date-str) "_"
                                  (match-string 2 date-str) "_"
                                  (match-string 3 date-str) "_"
                                  (match-string 4 date-str) "_"
                                  (match-string 5 date-str)))))
        (when (and dir-part date-part)
          (unless (file-directory-p save-dir)
            (make-directory save-dir t))
          (expand-file-name (concat date-part "__" dir-part ".org") save-dir))))))

(defun eej/copilot-chat-save-buffer ()
  "Save the current buffer if it is a Copilot chat buffer."
  (when (and (derived-mode-p 'org-mode)
             (string-match-p "\\`\\*Copilot" (buffer-name)))
    (when-let ((filename (eej/copilot-chat--compute-filename)))
      (write-region (point-min) (point-max) filename nil 'quiet))))

(defun eej/copilot-chat-auto-save-all ()
  "Auto-save all Copilot chat buffers."
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (eej/copilot-chat-save-buffer))))

(defun eej/copilot-chat-kill-hook ()
  "Save Copilot chat buffer before it is killed."
  (eej/copilot-chat-save-buffer))

(defun eej/copilot-chat--start-save-timer ()
  "Reset and start the periodic Copilot chat auto-save timer."
  (when (timerp eej/copilot-chat-save-timer)
    (cancel-timer eej/copilot-chat-save-timer))
  (setq eej/copilot-chat-save-timer
        (run-with-timer eej/copilot-chat-save-interval
                        eej/copilot-chat-save-interval
                        #'eej/copilot-chat-auto-save-all)))

(defun eej/copilot-chat-insert-session-metadata (buffer)
  "Insert session metadata at the top of BUFFER if freshly created."
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (and (derived-mode-p 'org-mode)
                 (save-excursion
                   (goto-char (point-min))
                   (not (looking-at-p "#\\+TITLE:"))))
        (save-excursion
          (goto-char (point-min))
          (let* ((dir (or default-directory "unknown"))
                 (branch (string-trim
                          (shell-command-to-string
                           (format "git -C %s rev-parse --abbrev-ref HEAD 2>/dev/null"
                                   (shell-quote-argument dir)))))
                 (timestamp (format-time-string "[%Y-%m-%d %a %H:%M]")))
            (insert "#+TITLE: Copilot Chat Session\n")
            (insert (format "#+DATE: %s\n" timestamp))
            (insert (format "#+PROPERTY: SESSION_DIR %s\n" dir))
            (insert (format "#+PROPERTY: GIT_BRANCH %s\n"
                            (if (string-empty-p branch) "N/A" branch)))
            (insert "\n")))))))

(defun eej/copilot-chat--insert-session-metadata-advice (buffer)
  "Advice helper that inserts session metadata in BUFFER."
  (eej/copilot-chat-insert-session-metadata buffer)
  buffer)

(defun eej/copilot-chat-add-heading-id (orig-fn instance content type)
  "Advise `copilot-chat--org-format-data' to inject :ID: property drawers."
  (let ((data (funcall orig-fn instance content type)))
    (cond
     ((eq type 'prompt)
      (let ((id (org-id-new)))
        (replace-regexp-in-string
         (regexp-quote (format-time-string "*[%T]* You\n"))
         (format-time-string (concat "*[%T]* You\n"
                                     ":PROPERTIES:\n"
                                     ":ID: " id "\n"
                                     ":END:\n"))
         data t t)))
     ((copilot-chat-first-word-answer instance)
      (if (string-match (concat ":" copilot-chat--org-answer-tag ":\n") data)
          (let ((id (org-id-new)))
            (replace-regexp-in-string
             (concat ":" copilot-chat--org-answer-tag ":\n")
             (format ":%s:\n:PROPERTIES:\n:ID: %s\n:END:\n"
                     copilot-chat--org-answer-tag id)
             data t t))
        data))
     (t data))))

(defun eej-copilot-chat-faces ()
  "Make user/AI headings visually distinct in Copilot Chat."
  (when (string-match-p "Copilot Chat" (buffer-name))
    (face-remap-add-relative 'org-level-1
                             '(:inverse-video t :weight bold))
    (face-remap-add-relative 'org-level-2
                             '(:weight semi-bold :foreground "gray70"))))

(defun eej/copilot-chat-enable ()
  "Enable Copilot Chat local extensions."
  (require 'org-id)
  (setq org-id-method 'ts)
  (add-hook 'kill-buffer-hook #'eej/copilot-chat-kill-hook)
  (add-hook 'org-mode-hook #'eej-copilot-chat-faces)
  (unless (advice-member-p #'eej/copilot-chat--insert-session-metadata-advice
                           'copilot-chat--org-get-buffer)
    (advice-add 'copilot-chat--org-get-buffer :filter-return
                #'eej/copilot-chat--insert-session-metadata-advice))
  (unless (advice-member-p #'eej/copilot-chat-add-heading-id
                           'copilot-chat--org-format-data)
    (advice-add 'copilot-chat--org-format-data :around
                #'eej/copilot-chat-add-heading-id))
  (eej/copilot-chat--start-save-timer))

(defvar-local eej/copilot-chat-filename nil
  "Deterministic filename for persisting this Copilot chat buffer.")

(defvar-local eej/copilot-chat-id nil
  "Persistent ID for this Copilot chat buffer (string).")

(defun eej/copilot-chat--ensure-metadata ()
  (unless eej/copilot-chat-filename
    (setq eej/copilot-chat-filename (eej/copilot-chat--compute-filename)))
  ;; you said you already keep persistent IDs; this is just a placeholder hook
  (unless eej/copilot-chat-id
    (setq eej/copilot-chat-id (or (bound-and-true-p copilot-chat-session-id)
                                  (format "copilot-%s" (md5 (buffer-name)))))))

(defun eej/org-store-link-for-copilot-chat ()
  "Store an Org link for Copilot chat buffers."
  (when (and (derived-mode-p 'org-mode)
             (string-match-p "\\`\\*Copilot" (buffer-name)))
    (eej/copilot-chat--ensure-metadata)
    (when (and eej/copilot-chat-filename eej/copilot-chat-id)
      ;; Ensure the link has a stable search target.
      ;; Option A: store a dedicated heading or CUSTOM_ID in the persisted file.
      ;; Here we assume the persisted transcript contains the id as a heading or token.
      (let* ((desc (format "Copilot chat: %s" (buffer-name)))
             (link (format "file:%s::*%s"
                           (expand-file-name eej/copilot-chat-filename)
                           eej/copilot-chat-id)))
        (org-link-store-props :type "file"
                              :link link
                              :description desc)
        link))))

;; Prepend so it runs before generic org handlers.
(add-hook 'org-store-link-functions #'eej/org-store-link-for-copilot-chat 0)

(provide 'copilot-chat-custom)
