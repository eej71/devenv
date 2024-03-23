;; Work customizations for org mode
(setq org-agenda-custom-commands
      '(
        ;; Gather up any TODO|STARTED items that are scheduled for the past, today, or tomorrow or any any STARTED tasks
        ;; For STARTED tasks, we only show the deepest started
        ("r" "Review" ((tags-todo "SCHEDULED<=\"<now>\"+TODO=\"STARTED\"|SCHEDULED=\"\"+TODO=\"STARTED\"|SCHEDULED<=\"<now>\"+TODO=\"TODO\"" ((org-agenda-overriding-header "Tasks") (org-agenda-skip-function 'eej/find-nested-started)))
                       ))

        ("a" "Agenda" ((agenda "" ((org-agenda-show-log t)
                                   (org-agenda-use-time-grid nil)
                                   (org-agenda-span 'day)
                                   (org-time-clocksum-format '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))
                                   (org-agenda-clockreport-parameter-plist '(:narrow 120 :stepskip0 t :indent t :fileskip0 t :link nil :maxlevel 4))
                                   ))))

        ;; Collects unscheduled WAITING tasks (not delegated)
        ("w" "WAITING" tags-todo "+SCHEDULED=\"\"+DEADLINE=\"\"/!WAITING")

        ("#" "Stuck Projects" tags-todo "TODO=\"TODO\"|TODO=\"STARTED\""
         ((org-agenda-skip-function 'eej/find-stuck-projects)
          (org-agenda-overriding-header "Stuck Projects")))

        ("n" "Next todos" tags-todo "+PRIORITY=\"A\"+TODO=\"TODO\"+SCHEDULED=\"\""
         ((org-agenda-overriding-header "Next TODOs")))
        ))

(setq org-capture-templates '(
                              ;; %i may not make sense as that's copy from region or something - may eliminate the stray \ns i think see
                              ("n" "Notes for the currently clocked in task" item (clock) "%U %?" :prepend t)
                              ))

(provide 'local-config)
