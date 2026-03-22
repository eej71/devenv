;;; package -- Summary:
;;; Commentary:

;;; Mode line

(require 'project)
(require 'vc)

(declare-function org-duration-from-minutes "org-duration" (minutes))
(declare-function org-clock-get-clocked-time "org-clock" ())
(defvar org-clock-current-task)
(defvar org-clock-heading)

;; other things to add in to this
;;
;; TOP/%99/BOT
;; LOCK unicode for read only
;; remote can probaby be changed once we understand tramp
;; (flymake stats? compilation stats?)
;; [project name] - independent color faces
;; [git branch name] - (vc-git--symbolic-ref (buffer-file-name)) - but needs to be safe for non git modelines
;; filename (relative for project) - (file-relative-name buffer-file-name (project-root (project-current))
;; org-clock-update-mode-line - org-mode-line-string - org-clock-update-time-maybe -- (org-clock-get-clock-string)

;; Should check how tramp filenames come out
;;; Faces to work on
;;; spectral-modeline-indicator-kdb-macro
;;
;; Strategy in here to really dim modeline for inactive windows https://emacs.stackexchange.com/questions/3518/how-should-i-dim-the-header-line-of-inactive-windows

;;; NEXT: Come up with a variable via dir-locals

(defgroup spectral-modeline nil "Custom modeline that looks nice." :group 'mode-line)

(defgroup spectral-modeline-faces nil
  "Faces for my eej modeline."
  :group 'spectral-modeline)

(defface spectral-modeline-saved-face nil
  "Face used to highlight when the file is saved."
  :group 'spectral-modeline-faces)

(defface spectral-modeline-kbd-macro-face nil
  "Face for keyboard macro recording indicator."
  :group 'spectral-modeline-faces)

(defface spectral-modeline-narrow-face nil
  "Face for narrowing indicator."
  :group 'spectral-modeline-faces)

(defface spectral-modeline-project-branch-face nil "Face for project:branch."  :group 'spectral-modeline-faces)
(defface spectral-modeline-buffer-identification-face nil "Face for the filename in the modeline." :group 'spectral-modeline-faces)

(defface spectral-modeline-org-task-active-face nil "Face for the org task when this is active." :group 'spectral-modeline-faces)
(defface spectral-modeline-org-task-inactive-face nil "Face for the org task when this is inactive." :group 'spectral-modeline-faces)

(defface spectral-modeline-org-no-task-active-face nil "Face for when there is no clocked in task for the active buffer." :group 'spectral-modeline-faces)
(defface spectral-modeline-org-no-task-inactive-face nil "Face for when there is no clocked in task for the inactive buffer." :group 'spectral-modeline-faces)
(defface spectral-modeline-inactive-face nil "Face for the inactive buffer's modeline." :group 'spectral-modeline-faces)

(defface spectral-modeline-modified-face nil
  "Face for modeline modified."
  :group 'spectral-modeline-faces)

(defun spectral-modeline--kbd-macro (active)
  "Return the kbd macro indicator - choose face based on ACTIVE."
      (when (and (mode-line-window-selected-p) defining-kbd-macro)
        (propertize " Macro " 'face 'spectral-modeline-kbd-macro-face)))

(defvar-local spectral-modeline-kbd-macro-active  '(:eval (spectral-modeline--kbd-macro t)) "Mode line to indicate when defining-kdb-macro.")
(defvar-local spectral-modeline-kbd-macro-inactive '(:eval (spectral-modeline--kbd-macro nil))  "Mode line to indicate when defining-kdb-macro.")


(defun spectral-modeline--narrow (active)
  "Return the narrow indicator - choose face based on ACTIVE."
  (when (and (mode-line-window-selected-p)
             (buffer-narrowed-p)
             (not (derived-mode-p 'Info-mode 'help-mode 'special-mode 'message-mode)))
    (propertize " Narrow " 'face 'spectral-modeline-narrow-face)))

(defvar-local spectral-modeline-narrow-active '(:eval (spectral-modeline--narrow t)) "Mode line to indicate narrow range.")
(defvar-local spectral-modeline-narrow-inactive '(:eval (spectral-modeline--narrow nil)) "Mode line to indicate narrow range.")
(defvar-local spectral-modeline-project-branch-face 'spectral-modeline-project-branch-face "Default face to use for project in modeline.")

(defun spectral-modeline-project-name ()
  "Return name of the project as is."
  (let ((this-project (project-current nil (file-truename default-directory))))
    (if this-project
        (file-name-nondirectory (directory-file-name (project-root this-project)))
    "-" )))

(defun spectral-modeline-git-name ()
  "Return the current branch name for Git."
  (when-let* ((file (file-truename (or buffer-file-name default-directory)))
              (backend (vc-responsible-backend file t))
              ((eq backend 'Git)))
    (or (when-let ((ml (ignore-errors
                         (vc-call-backend backend 'mode-line-string file))))
          (if (string-match "\\`\\s-*Git[:-]\\(.+\\)\\'" ml)
              (match-string 1 ml)
            ml))
        (ignore-errors (vc-git--symbolic-ref file)))))

(defun spectral-modeline--compute-project-branch-face (project)
  "Return the face for this particular `PROJECT` branch."
  spectral-modeline-project-branch-face)

(defun spectral-modeline--project-branch (active)
  "Return the text and face for the project-branch based on ACTIVE."
  (if (and buffer-file-name (project-current nil (file-truename default-directory)))
      (let ((project-name (spectral-modeline-project-name)))
        (let ((retval (format "{%s:%s}" project-name (or (spectral-modeline-git-name) "-"))))
          (if active
              (propertize retval 'face (spectral-modeline--compute-project-branch-face project-name))
            retval)))
    nil))

(defvar-local spectral-modeline-project-branch-active '(:eval (spectral-modeline--project-branch t)))
(defvar-local spectral-modeline-project-branch-inactive '(:eval (spectral-modeline--project-branch nil)))

(defun spectral-modeline-format-filename ()
  "Return the current filename relative to the project root."
  (let ((true-buffer-file-name (and buffer-file-name (file-truename buffer-file-name)))
        (the-project (project-current nil (file-truename default-directory))))
    (if (and true-buffer-file-name the-project)
        (file-relative-name true-buffer-file-name (project-root the-project))
      (buffer-name))))

(defun spectral-modeline--buffer-identification (active)
  "Return the buffer id based on ACTIVE."
  (propertize (spectral-modeline-format-filename)
              'face 'spectral-modeline-buffer-identification-face))

(defvar-local spectral-modeline-buffer-identification-active '(:eval (spectral-modeline--buffer-identification t)))
(defvar-local spectral-modeline-buffer-identification-inactive '(:eval (spectral-modeline--buffer-identification nil)))

;; TODO: you could perhaps format - on your own - (org-duration-from-minutes (org-clock-get-clocked-time)) and org-clock-heading or org-clock-current-task
;; lets you fixed up the face...

(defun eej-org--task (active)
  "Return the org task if any based on ACTIVE."
  (if (and (boundp 'org-clock-current-task) org-clock-current-task)
      (propertize (format "[%s] %s" (org-duration-from-minutes (org-clock-get-clocked-time)) org-clock-heading)
                  'face
                  (if active
                      'spectral-modeline-org-task-active-face
                    'spectral-modeline-org-task-inactive-face))

    ;; Propertize this separately from the others
    (propertize "No current org clock"
                'face
                (if active
                    'spectral-modeline-org-no-task-active-face
                  'spectral-modeline-org-no-task-inactive-face))))

(defvar-local eej-org-task-active '(:eval (eej-org--task t)))
(defvar-local eej-org-task-inactive '(:eval (eej-org--task nil)))

(defun eej-buffer--pos (active)
  "Return the buffer position based on ACTIVE."
  (list 3
        (propertize "%3p"
                    'face
                    (if (not active)
                        'spectral-modeline-inactive-face
                      (if (and buffer-file-name (buffer-modified-p))
                          'spectral-modeline-modified-face
                        'spectral-modeline-saved-face)))))
  
(defvar-local eej-buffer-pos-active '(:eval (eej-buffer--pos t)))
(defvar-local eej-buffer-pos-inactive '(:eval (eej-buffer--pos nil)))

(defun eej-buffer--read-state (active)
  "Return a unicode lock character if its read-only based on ACTIVE."
  (if buffer-read-only
      "  " ;; char-to-string xE0A2
    "   "))

(defvar-local eej-buffer-read-state-active '(:eval (eej-buffer--read-state t)))
(defvar-local eej-buffer-read-state-inactive '(:eval (eej-buffer--read-state nil)))

(require 'flymake)
(defun eej-buffer--flymake-state (active)
  "Return flymake counters - but only for `prog-mode' related buffer and ACTIVE."
  (if (or (not active)
          (not (derived-mode-p 'prog-mode))
          (not (bound-and-true-p flymake-mode)))
      nil
    (list flymake-mode-line-exception
          flymake-mode-line-counters)))

(defvar-local eej-flymake-state-active '(:eval (eej-buffer--flymake-state t)))
(defvar-local eej-flymake-state-inactive '(:eval (eej-buffer--flymake-state nil)))

;; TODO: Just visit the elements in mode-line-format and figure it out?
(dolist (construct '(spectral-modeline-kbd-macro-active
                     spectral-modeline-kbd-macro-inactive

                     spectral-modeline-narrow-active
                     spectral-modeline-narrow-inactive

                     eej-buffer-pos-active
                     eej-buffer-pos-inactive

                     eej-buffer-read-state-active
                     eej-buffer-read-state-inactive

                     spectral-modeline-project-branch-active
                     spectral-modeline-project-branch-inactive

                     spectral-modeline-buffer-identification-active
                     spectral-modeline-buffer-identification-inactive

                     eej-org-task-active
                     eej-org-task-inactive

                     eej-flymake-state-active
                     eej-flymake-state-inactive
                     ))
  (put construct 'risky-local-variable t))

;;; Code:
(defvar spectral-modeline-format-active nil
  "Modeline layout to use for the selected window.")

(defvar spectral-modeline-format-inactive nil
  "Modeline layout to use for unselected windows.")

(defvar spectral-modeline-format nil
  "Single modeline entry that selects active/inactive layout per window.")

(setq spectral-modeline-format-active
      '("%e" ;; out of memory condition, which is never used
        spectral-modeline-kbd-macro-active
        spectral-modeline-narrow-active

        eej-buffer-pos-active
        eej-buffer-read-state-active
        spectral-modeline-project-branch-active

        " "
        spectral-modeline-buffer-identification-active
        "  || "

        eej-org-task-active

        mode-line-format-right-align

        (:eval
         (when-let ((path (window-parameter nil 'ace-window-path)))
           (format " [%s]" path)))

        ;; TODO: These need to be wrapped in a prog-mode check I think
        eej-flymake-state-active
        ))

(setq spectral-modeline-format-inactive
      '("%e" ;; out of memory condition, which is never used
        spectral-modeline-kbd-macro-inactive
        spectral-modeline-narrow-inactive

        eej-buffer-pos-inactive
        eej-buffer-read-state-inactive
        spectral-modeline-project-branch-inactive

        " "
        spectral-modeline-buffer-identification-inactive
        "  || "

        eej-org-task-inactive
        mode-line-format-right-align

        (:eval
         (when-let ((path (window-parameter nil 'ace-window-path)))
           (format " [%s]" path)))

        ;; TODO: These need to be wrapped in a prog-mode check I think
        eej-flymake-state-inactive
        ))

(setq spectral-modeline-format
      '(:eval
        (if (mode-line-window-selected-p)
            spectral-modeline-format-active
          spectral-modeline-format-inactive)))

(defvar spectral-header-line-format
  '(:eval
    (let* ((name (format " %s " (spectral-modeline-format-filename)))
           (fill (make-string (max 0 (- (window-total-width) (length name))) ?\s)))
      (if (mode-line-window-selected-p)
          (concat (propertize name 'face '(:foreground "#000000" :background "#ffffff" :weight bold))
                  (propertize fill 'face '(:background "#3333ff")))
        (propertize (concat name fill)
                    'face '(:foreground "#989898" :background "#181818")))))
  "Header line format for active/inactive window perimeter highlighting.")
(put 'spectral-header-line-format 'risky-local-variable t)

(defun eej-modeline-restore-default ()
  "Restore the custom modeline defaults after startup."
  ;; Clean up older per-buffer locals created by legacy hook-based switching.
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (and (local-variable-p 'mode-line-format)
                 (memq mode-line-format
                       (list spectral-modeline-format-active
                             spectral-modeline-format-inactive)))
        (kill-local-variable 'mode-line-format))))
  (setq-default mode-line-format (list spectral-modeline-format))
  (setq-default header-line-format (list spectral-header-line-format))
  (force-mode-line-update t))

(add-hook 'after-init-hook #'eej-modeline-restore-default)
(eej-modeline-restore-default)
(provide 'modeline)
