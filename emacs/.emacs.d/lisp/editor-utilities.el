;;; editor-utilities.el --- General editor utilities -*- lexical-binding: t; -*-
;;
;;
;;; Commentary:
;; General purpose editor utility functions

;;; Code:

(require 'project)

(defun eej/is-buffer-read-only ()
  "Set the buffer to read-only if it's a file outside of a project."
  (when (and buffer-file-name
             (not (project-current nil (file-truename default-directory))))
    (read-only-mode t)))

(defun eej/prog-mode-setup ()
  "Perform all the required setup for a prog mode."
  (setq-local indent-tabs-mode nil)
  (setq-local buffer-display-table (make-display-table))
  (aset buffer-display-table ?\^M [])
  (display-line-numbers-mode t)
  (whitespace-mode t)
  (setq-local fill-column 120)
  (setq-local nxml-slash-auto-complete-flag t)
  (flymake-mode +1)
  (electric-pair-local-mode t))

(defun eej-resize-window-hydra ()
  "Interactively resize window with arrow keys. Press q to quit."
  (interactive)
  (let ((done nil))
    (while (not done)
      (let ((key (read-key
                  (format "Resize: [←] narrower [→] wider [↑] taller [↓] shorter [q]uit"))))
        (cond
         ((eq key 'left)  (shrink-window-horizontally 3))
         ((eq key 'right) (enlarge-window-horizontally 3))
         ((eq key 'down)    (enlarge-window 2))
         ((eq key 'up)  (shrink-window 2))
         (t (setq done t)))))))

(defun spectral-enable-colorized-words ()
  "Colorizes strings with the right color."
  (rainbow-mode 1))


(use-package vterm
  :straight t
  :config
  (setq vterm-shell "bash"))

(use-package multi-vterm
  :after vterm
  :bind (("C-c v n" . multi-vterm)
         ("C-c v p" . multi-vterm-prev)
         ("C-c v N" . multi-vterm-next)))


(require 'tramp)
(require 'vterm)

(defun eej/vterm-here ()
  "Open vterm in `default-directory`. If remote (TRAMP), ssh to that host and cd."
  (interactive)
  (let* ((dir default-directory)
         (remote (file-remote-p dir))
         (vec (and remote (tramp-dissect-file-name dir)))
         (host (and vec (tramp-file-name-host vec)))
         (user (and vec (tramp-file-name-user vec)))
         (path (and vec (tramp-file-name-localname vec)))
         (target (if user (format "%s@%s" user host) host))
         (bufname (if remote (format "*vterm:%s*" host) "*vterm*")))
    (vterm bufname)
    (when remote
      ;; Hop into the host and land in the same directory.
      (vterm-send-string
       (format "ssh -t %s 'cd %s && exec $SHELL -l'"
               target (shell-quote-argument path)))
      (vterm-send-return))))

(global-set-key (kbd "C-c t") #'eej/vterm-here)

(provide 'editor-utilities)
;;; editor-utilities.el ends here
