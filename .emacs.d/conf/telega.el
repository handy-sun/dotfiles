;;; telega.el --- Telegram client -*- lexical-binding: t; -*-

;; ============================================================
;; Runtime paths
;; ============================================================
(defconst my/telega-data-directory
  (expand-file-name "telega"
                    (or (getenv "XDG_DATA_HOME")
                        (expand-file-name ".local/share" "~"))))

(defconst my/telega-cache-directory
  (expand-file-name "telega"
                    (or (getenv "XDG_CACHE_HOME")
                        (expand-file-name ".cache" "~"))))

(defconst my/telega-temp-directory
  (expand-file-name "telega" temporary-file-directory))

;; ============================================================
;; Telega
;; ============================================================
(use-package telega
  ;; Install from MELPA via straight.el's recipe repository.
  ;; This pulls telega.el and builds the bundled telega-server; the C build
  ;; still requires a matching TDLib installed at runtime (see manual:
  ;; https://zevlg.github.io/telega.el/#linux-users).
  :straight t
  :commands (telega
             telega-account-switch
             telega-chat-with
             telega-saved-messages
             telega-switch-buffer
             telega-switch-important-chat
             telega-switch-unread-chat)
  :bind-keymap ("C-c T" . telega-prefix-map)
  :init
  ;; Set this before loading telega; cache/temp/log defaults derive from it.
  (setq telega-directory my/telega-data-directory)
  (setq telega-cache-dir my/telega-cache-directory)
  (setq telega-temp-dir my/telega-temp-directory)
  (setq telega-server-logfile
        (expand-file-name "telega-server.log" my/telega-cache-directory))
  (dolist (dir (list telega-directory
                     telega-cache-dir
                     telega-temp-dir
                     (file-name-directory telega-server-logfile)))
    (make-directory dir t))
  :custom
  ;; TDLib install prefix (must contain include/ and lib/). On NixOS this is
  ;; exported by home-manager as TELEGA_TDLIB_PREFIX pointing at pkgs.tdlib;
  ;; elsewhere fall back to the usual /usr/local. telega-server-build links
  ;; against $prefix/lib with an rpath, so no LD_LIBRARY_PATH is needed.
  (telega-server-libs-prefix (or (getenv "TELEGA_TDLIB_PREFIX") "/usr/local"))
  (telega-root-fill-column 100)
  (telega-chat-fill-column 90)
  (telega-chat-buffers-limit 10))

;; ============================================================
;; Clipboard image paste (Wayland-safe)
;; ------------------------------------------------------------
;; telega-chatbuf-attach-clipboard (C-c C-v) reads the clipboard via
;; gui-get-selection. On PGTK/Wayland, when the clipboard holds only an
;; image, (gui-get-selection 'CLIPBOARD 'TARGETS) returns the bare symbol
;; `image/png' instead of a vector, so telega's cl-position signals
;; "Wrong type argument: sequencep, image/png". Bypass that path by pulling
;; the image straight from the Wayland clipboard with wl-paste.
;; ============================================================
(defun my/telega-attach-clipboard-image ()
  "Attach the clipboard image to the telega chatbuf via wl-paste."
  (interactive)
  (unless (executable-find "wl-paste")
    (error "wl-paste not found; install wl-clipboard"))
  (let* ((temporary-file-directory telega-temp-dir)
         (tmpfile (telega-temp-name "clipboard" ".png")))
    (unless (zerop (call-process "wl-paste" nil (list :file tmpfile) nil
                                 "-t" "image/png"))
      (error "No image/png in clipboard"))
    (telega-chatbuf-attach-media tmpfile)))

(with-eval-after-load 'telega
  (define-key telega-chat-mode-map (kbd "C-c C-v")
              #'my/telega-attach-clipboard-image))

(with-eval-after-load 'general
  (my/leader
    "tt" 'telega
    "ta" 'telega-account-switch
    "tb" 'telega-switch-buffer
    "tc" 'telega-chat-with
    "ti" 'telega-switch-important-chat
    "ts" 'telega-saved-messages
    "tu" 'telega-switch-unread-chat))

(provide 'conf-telega)
;;; telega.el ends here
