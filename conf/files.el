;;; files.el --- File management -*- lexical-binding: t; -*-

;; ============================================================
;; Treemacs (like NERDTree: file tree sidebar)
;; ============================================================
(use-package treemacs
  :bind ("C-c t" . treemacs)
  :custom
  (treemacs-width 30)
  (treemacs-show-hidden-files t)
  (treemacs-is-never-other-window t)
  (treemacs-sorting 'alphabetic-asc)
  (treemacs-indentation 2)
  (treemacs-indentation-string "⎸")
  (treemacs-git-mode 'deferred))

(use-package treemacs-evil
  :after (treemacs evil))

(use-package treemacs-magit
  :after (treemacs magit))

;; ============================================================
;; Dired (built-in file manager)
;; ============================================================
(use-package dired
  :straight nil
  :custom
  (dired-listing-switches "-alh --group-directories-first")
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-dwim-target t)
  (dired-recursive-copies 'always)
  (dired-recursive-deletes 'always))

;; Dired subtree (expand directories inline)
(use-package dired-subtree
  :after dired
  :bind (:map dired-mode-map
         ("TAB" . dired-subtree-toggle)))

;; Dired icons (file type icons)
(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; ============================================================
;; Project (built-in project management)
;; ============================================================
(use-package project
  :straight nil
  :custom
  (project-switch-commands 'project-find-file))

(provide 'files)
;;; files.el ends here
