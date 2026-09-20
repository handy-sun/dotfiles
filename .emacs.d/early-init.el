;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-

;; Defer GC during startup for faster boot
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 16 1024 1024))))

;; Disable UI elements early
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
;; pgtk derives the default frame height from the display's physical pixels,
;; but niri's work area is logical (physical / scale), so on scaled outputs
;; the initial frame opens taller than the screen (36 lines = 1082px on a
;; 1080p panel at 1.1x). Pin a line count that fits every host; with the
;; Maple Mono NF CN default font (conf/ui.el) one line is ~30px, so 30 lines
;; (~902px) clears even a 941px work area.
(push '(height . 30) default-frame-alist)
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;; Prevent package.el from auto-installing (we use straight.el)
(setq package-enable-at-startup nil)

;; False-positive "not known to be defined" warnings from the async native
;; compiler, which compiles each file in isolation:
;; - evil-collection-pdf calls `image-set-window-hscroll', which image-mode.el
;;   defines without an autoload.
;; - general.el's `general-evil-setup' references `general-nmap' & co. via
;;   `#'', but those are only defalias'd at runtime by earlier
;;   `general-create-definer' expansions in the same function (conf/evil.el
;;   calls it with short-names).
;; Skip native-compiling these files; bytecode behaves identically.
(with-eval-after-load "comp-run"
  (dolist (re '("evil-collection-pdf\\.el\\'" "general\\.el\\'"))
    (add-to-list 'native-comp-jit-compilation-deny-list re)))

(provide 'early-init)
;;; early-init.el ends here
