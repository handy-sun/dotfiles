;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Defer GC during startup for faster boot
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; Disable UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;; Prevent package.el from auto-installing (we use straight.el)
(setq package-enable-at-startup nil)

(provide 'early-init)
;;; early-init.el ends here
