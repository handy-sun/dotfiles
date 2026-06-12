;;; ui.el --- UI configuration -*- lexical-binding: t; -*-

;; ============================================================
;; Theme (like set background=dark + colorscheme)
;; ============================================================
(use-package doom-themes
  :demand t
  :config
  (load-theme 'doom-one t)            ; OneDark style dark theme
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (treemacs integration)
  (doom-themes-treemacs-config)
  ;; Corrects org-mode's native fontification
  (doom-themes-org-config))

;; ============================================================
;; Modeline (like vim-airline)
;; ============================================================
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 25)
  (doom-modeline-bar-width 3)
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-minor-modes nil))

;; ============================================================
;; Line numbers (like set number relativenumber)
;; ============================================================
;; Already set in basic.el via display-line-numbers
;; Highlight current line (like set cursorline)
(global-hl-line-mode 1)

;; ============================================================
;; Rainbow delimiters (like vim-rainbow)
;; ============================================================
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; ============================================================
;; Indent guides (like indentLine)
;; ============================================================
(use-package highlight-indent-guides
  :hook (prog-mode . highlight-indent-guides-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-character ?⎸)
  (highlight-indent-guides-responsive 'top))

;; ============================================================
;; Smooth scrolling (like vim-smoothie)
;; ============================================================
(pixel-scroll-precision-mode 1)       ; Emacs 29+ built-in

;; ============================================================
;; Highlight on yank (like vim-highlightedyank)
;; ============================================================
(defun my/highlight-yank (&rest _)
  "Highlight the yanked region briefly."
  (when (and (not (minibufferp)) (not (eq this-command 'yank-pop)))
    (pulse-momentary-highlight-region (region-beginning) (region-end))))

(advice-add 'evil-yank :after 'my/highlight-yank)

;; ============================================================
;; Which-key (show keybindings in popup)
;; ============================================================
(use-package which-key
  :hook (after-init . which-key-mode)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-sort-order 'which-key-key-order-alpha)
  (which-key-side-window-max-height 0.25)
  (which-key-show-early-on-C-h t)
  (which-key-max-description-length 35))

;; ============================================================
;; Font
;; ============================================================
(set-face-attribute 'default nil
                    :family "JetBrains Mono"
                    :height 130
                    :weight 'normal)

;; Fallback for CJK
(set-fontset-font t 'han
                  (font-spec :family "Noto Sans CJK SC" :size 14) nil 'append)

(provide 'ui)
;;; ui.el ends here
