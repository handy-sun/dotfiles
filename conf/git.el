;;; git.el --- Git integration -*- lexical-binding: t; -*-

;; ============================================================
;; Magit (like vim-fugitive, but way better)
;; ============================================================
(use-package magit
  :bind ("C-x g" . magit-status)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-save-repository-buffers 'dontask)
  (magit-revision-show-gravatars t))

;; Magit forge (GitHub/GitLab integration)
(use-package forge
  :after magit
  :defer t)

;; ============================================================
;; Diff-hl (like vim-gitgutter: show git changes in gutter)
;; ============================================================
(use-package diff-hl
  :hook ((after-init . global-diff-hl-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :custom
  (diff-hl-side 'left)
  (diff-hl-flydiff-delay 0.3))

;; ============================================================
;; Git-timemachine (browse file history)
;; ============================================================
(use-package git-timemachine
  :defer t)

;; ============================================================
;; Smerge (merge conflict resolution)
;; ============================================================
(use-package smerge-mode
  :ensure nil
  :hook (prog-mode . smerge-mode))

(provide 'git)
;;; git.el ends here
