;;; package -- Summary:
;;; Commentary:

;;; Mode line

(require 'project)
(require 'vc-git)
(require 'org)
(require 'org-clock)

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
;;; eej-modeline-indicator-kdb-macro
;;
;; Strategy in here to really dim modeline for inactive windows https://emacs.stackexchange.com/questions/3518/how-should-i-dim-the-header-line-of-inactive-windows

;;; NEXT: Come up with a variable via dir-locals

(defgroup eej-modeline nil "Custom modeline that looks nice." :group 'mode-line)

(defgroup eej-modeline-faces nil
  "Faces for my eej modeline."
  :group 'eej-modeline)

(defface eej-modeline-saved-face nil
  "Face used to highlight when the file is saved."
  :group 'eej-modeline-faces)

(defface eej-modeline-project-branch-face nil "Face for project:branch."  :group 'eej-modeline-faces)
(defface eej-modeline-buffer-identification-face nil "Face for the filename in the modeline." :group 'eej-modeline-faces)

(defface eej-modeline-org-task-active-face nil "Face for the org task when this is active." :group 'eej-modeline-faces)
(defface eej-modeline-org-task-inactive-face nil "Face for the org task when this is inactive." :group 'eej-modeline-faces)

(defface eej-modeline-org-no-task-active-face nil "Face for when there is no clocked in task for the active buffer." :group 'eej-modeline-faces)
(defface eej-modeline-org-no-task-inactive-face nil "Face for when there is no clocked in task for the inactive buffer." :group 'eej-modeline-faces)
(defface eej-modeline-inactive-face nil "Face for the inactive buffer's modeline." :group 'eej-modeline-faces)

(defface eej-modeline-modified-face nil
  "Face for modeline modified."
  :group 'eej-modeline-faces)

(defun eej-modeline--kbd-macro (active)
  "Return the kbd macro indicator - choose face based on ACTIVE."
      (when (and (mode-line-window-selected-p) defining-kbd-macro)
        (propertize " Macro " 'face 'eej-modeline-kbd-macro-face)))

(defvar-local eej-modeline-kbd-macro-active  '(:eval (eej-modeline--kbd-macro t)) "Mode line to indicate when defining-kdb-macro.")
(defvar-local eej-modeline-kbd-macro-inactive '(:eval (eej-modeline--kbd-macro nil))  "Mode line to indicate when defining-kdb-macro.")


(defun eej-modeline--narrow (active)
  "Return the narrow indicator - choose face based on ACTIVE."
  (when (and (mode-line-window-selected-p)
             (buffer-narrowed-p)
             (not (derived-mode-p 'Info-mode 'help-mode 'special-mode 'message-mode)))
    (propertize " Narrow " 'face 'eej-modeline-narrow-face)))

(defvar-local eej-modeline-narrow-active '(:eval (eej-modeline--narrow t)) "Mode line to indicate narrow range.")
(defvar-local eej-modeline-narrow-inactive '(:eval (eej-modeline--narrow nil)) "Mode line to indicate narrow range.")
(defvar-local eej-modeline-project-branch-face 'eej-modeline-project-branch-face "Default face to use for project in modeline.")

(defun eej-modeline-project-name ()
  "Return name of the project as is."
  (let ((this-project (project-current nil (file-truename default-directory))))
    (if this-project
        (file-name-nondirectory (directory-file-name (project-root this-project)))
    "-" )))

(defun eej-modeline-git-name ()
  "Return the current branch name - assumes git."
  (vc-git--symbolic-ref (buffer-file-name)))

(defun eej-modeline--compute-project-branch-face (project)
  "Return the face for this particular `PROJECT` branch."
  eej-modeline-project-branch-face)

(defun eej-modeline--project-branch (active)
  "Return the text and face for the project-branch based on ACTIVE."
  (if (and buffer-file-name (project-current nil (file-truename default-directory)))
      (let ((project-name (eej-modeline-project-name)))        
        (let ((retval (format "{%s:%s}" project-name (eej-modeline-git-name))))
          (if active
              (propertize retval 'face (eej-modeline--compute-project-branch-face project-name))
            retval)))
    nil))

(defvar-local eej-modeline-project-branch-active '(:eval (eej-modeline--project-branch t)))
(defvar-local eej-modeline-project-branch-inactive '(:eval (eej-modeline--project-branch nil)))

(defun eej-modeline-format-filename ()
  "Return the current filename relative to the project root."
  (let ((true-buffer-file-name (and buffer-file-name (file-truename buffer-file-name)))
        (the-project (project-current nil (file-truename default-directory))))
    (if (and true-buffer-file-name the-project)
        (file-relative-name true-buffer-file-name (project-root the-project))
      (buffer-name))))

(defun eej-modeline--buffer-identification (active)
  "Return the buffer id based on ACTIVE."
  (propertize (eej-modeline-format-filename)
              'face 'eej-modeline-buffer-identification-face))

(defvar-local eej-modeline-buffer-identification-active '(:eval (eej-modeline--buffer-identification t)))
(defvar-local eej-modeline-buffer-identification-inactive '(:eval (eej-modeline--buffer-identification nil)))

;; TODO: you could perhaps format - on your own - (org-duration-from-minutes (org-clock-get-clocked-time)) and org-clock-heading or org-clock-current-task
;; lets you fixed up the face...

(defun eej-org--task (active)
  "Return the org task if any based on ACTIVE."
  (if (and (boundp 'org-clock-current-task) org-clock-current-task)
      (propertize (format "[%s] %s" (org-duration-from-minutes (org-clock-get-clocked-time)) org-clock-heading)
                  'face
                  (if active
                      'eej-modeline-org-task-active-face
                    'eej-modeline-org-task-inactive-face))

    ;; Propertize this separately from the others
    (propertize "No current org clock"
                'face
                (if active
                    'eej-modeline-org-no-task-active-face
                  'eej-modeline-org-no-task-inactive-face))))

(defvar-local eej-org-task-active '(:eval (eej-org--task t)))
(defvar-local eej-org-task-inactive '(:eval (eej-org--task nil)))

(defun eej-buffer--pos (active)
  "Return the buffer position based on ACTIVE."
  (list 3
        (propertize "%3p"
                    'face
                    (if (not active)
                        'eej-modeline-inactive-face
                      (if (and buffer-file-name (buffer-modified-p))
                          'eej-modeline-modified-face
                        'eej-modeline-saved-face)))))
  
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
  (if (not (derived-mode-p 'prog-mode))
      nil
    (if active
        (append (flymake--mode-line-exception)
                (flymake--mode-line-counters))
      nil)))

(defvar-local eej-flymake-state-active '(:eval (eej-buffer--flymake-state t)))
(defvar-local eej-flymake-state-inactive '(:eval (eej-buffer--flymake-state nil)))

;; TODO: Just visit the elements in mode-line-format and figure it out?
(dolist (construct '(eej-modeline-kbd-macro-active
                     eej-modeline-kbd-macro-inactive

                     eej-modeline-narrow-active
                     eej-modeline-narrow-inactive

                     eej-buffer-pos-active
                     eej-buffer-pos-inactive

                     eej-buffer-read-state-active
                     eej-buffer-read-state-inactive

                     eej-modeline-project-branch-active
                     eej-modeline-project-branch-inactive

                     eej-modeline-buffer-identification-active
                     eej-modeline-buffer-identification-inactive

                     eej-org-task-active
                     eej-org-task-inactive

                     eej-flymake-state-active
                     eej-flymake-state-inactive
                     ))
  (put construct 'risky-local-variable t))

;;; Code:
(setq eej-modeline-format-active
      '("%e" ;; out of memory condition, which is never used
        eej-modeline-kbd-macro-active
        eej-modeline-narrow-active
        
        eej-buffer-pos-active
        eej-buffer-read-state-active
        eej-modeline-project-branch-active

        " "
        eej-modeline-buffer-identification-active
        "  || "

        eej-org-task-active

        mode-line-format-right-align

        ;; TODO: These need to be wrapped in a prog-mode check I think
        eej-flymake-state-active
        ))

(setq eej-modeline-format-inactive
      '("%e" ;; out of memory condition, which is never used
        eej-modeline-kbd-macro-active
        eej-modeline-narrow-active
        
        eej-buffer-pos-active
        eej-buffer-read-state-active
        eej-modeline-project-branch-active

        " "
        eej-modeline-buffer-identification-inactive
        "  || "

        eej-org-task-inactive
        mode-line-format-right-align

        ;; TODO: These need to be wrapped in a prog-mode check I think
        eej-flymake-state-inactive
        ))


(setq-default mode-line-format 'eej-modeline-format-active)

(defun eej-set-modeline-format ()
  "Set the modeline format based on whether its active or inactive."
  (mapc
   (lambda (window)
     (with-current-buffer (window-buffer window)
       (if (eq window (selected-window))
           (setq mode-line-format eej-modeline-format-active)
         (setq mode-line-format eej-modeline-format-inactive))))
   (window-list)))
(add-hook 'buffer-list-update-hook #'eej-set-modeline-format)
(provide 'modeline)
