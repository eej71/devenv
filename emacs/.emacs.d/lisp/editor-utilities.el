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

(provide 'editor-utilities)
;;; editor-utilities.el ends here
