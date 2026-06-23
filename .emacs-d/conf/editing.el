;;; editing.el --- Editing enhancements -*- lexical-binding: t; -*-

;; ============================================================
;; Expreg (like iswap.nvim: expand selection by syntax tree)
;; ============================================================
(use-package expreg
  :bind ("C-=" . expreg-expand))

;; ============================================================
;; Easy-align (like vim-easy-align)
;; ============================================================
(use-package evil-lion
  :after evil
  :config
  (evil-lion-mode))                    ; gl / gL to align

;; ============================================================
;; Fold (code folding, like set foldmethod)
;; ============================================================
;; hideshow is built-in, configured in evil.el via hs-toggle-hiding
(add-hook 'prog-mode-hook 'hs-minor-mode)

;; treesit-fold for treesitter-based folding (Emacs 29+)
(use-package treesit-fold
  :hook (tree-sitter-after-on-hook . treesit-fold-mode)
  :defer t)

;; ============================================================
;; Undo-tree (visual undo history, like vim persistent undo)
;; ============================================================
;; Emacs 29+ has built-in undo-redo, which evil.el uses via evil-undo-system
;; If you want a visual tree: (uncomment below)
;; (use-package vundo
;;   :bind ("C-x u" . vundo))

;; ============================================================
;; Query replace with symbol at point (like sa/sr in vimrc)
;; ============================================================
(defun query-replace-symbol-at-point ()
  "Replace symbol at point in the entire buffer."
  (interactive)
  (let ((sym (thing-at-point 'symbol t)))
    (when sym
      (query-replace sym
                     (read-string (format "Replace '%s' with: " sym)
                                  sym)
                     nil
                     (point-min) (point-max)))))

;; ============================================================
;; Whitespace cleanup
;; ============================================================
;; Show trailing whitespace (like set list)
(setq-default show-trailing-whitespace t)

;; Clean up on save (like <leader>W :%s/\s\+$//)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; ============================================================
;; Parens / brackets (like auto-pairs + rainbow)
;; ============================================================
;; electric-pair-mode is already enabled in basic.el
;; rainbow-delimiters is in ui.el

;; Smartparens (more advanced paren manipulation, optional)
;; (use-package smartparens
;;   :hook (prog-mode . smartparens-strict-mode))

;; ============================================================
;; Yank from system clipboard
;; ============================================================
(setq select-enable-clipboard t)
(setq select-enable-primary t)

;; ============================================================
;; Multiple cursors (optional, like vim-multiple-cursors)
;; ============================================================
(use-package evil-mc
  :after evil
  :config
  (global-evil-mc-mode 1))

;; ============================================================
;; Drag-stuff (move selected text up/down, like S-Up/Down in visual)
;; ============================================================
(use-package drag-stuff
  :hook (after-init . drag-stuff-mode)
  :config
  (add-to-list 'drag-stuff-except-modes 'org-mode))

(provide 'editing)
;;; editing.el ends here
