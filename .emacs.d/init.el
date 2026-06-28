;;; init.el --- Emacs configuration -*- lexical-binding: t; -*-

;; ============================================================
;; Bootstrap straight.el
;; ============================================================
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package and integrate with straight.el
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

;; ============================================================
;; Load config modules
;; ============================================================
(defun my/load-config (module)
  "Load a config module from conf/ directory."
  (let ((file (expand-file-name
               (concat "conf/" (symbol-name module) ".el")
               user-emacs-directory)))
    (if (file-exists-p file)
        (load file nil 'nomessage)
      (warn "Config module not found: %s" file))))

(my/load-config 'basic)
(my/load-config 'ui)
(my/load-config 'evil)
(my/load-config 'completion)
(my/load-config 'git)
(my/load-config 'files)
(my/load-config 'editing)
(my/load-config 'lang)
(my/load-config 'telega)

;;; init.el ends here
