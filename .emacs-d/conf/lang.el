;;; lang.el --- Language support -*- lexical-binding: t; -*-

;; ============================================================
;; Treesitter (syntax highlighting + structural editing)
;; ============================================================
;; Emacs 29+ has built-in treesit
(when (fboundp 'treesit-available-p)
  (setq treesit-font-lock-level 4))

;; Auto-install treesitter grammars
(use-package treesit-auto
  :hook (after-init . global-treesit-auto-mode)
  :custom
  (treesit-auto-install 'prompt))

;; ============================================================
;; LSP (like ALE/coc.nvim for completion & diagnostics)
;; ============================================================
(use-package eglot
  :straight nil                         ; built-in Emacs 29+
  :hook ((python-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (go-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (typescript-mode . eglot-ensure)
         (js-mode . eglot-ensure))
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  :config
  ;; Add servers as needed
  (add-to-list 'eglot-server-programs
               '(rust-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(go-mode . ("gopls"))))

;; ============================================================
;; Flycheck (syntax checking, like ALE)
;; ============================================================
(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-check-syntax-automatically '(save mode-enabled))
  (flycheck-idle-change-delay 0.5))

;; ============================================================
;; Language-specific settings
;; ============================================================

;; YAML (like au FileType yaml set shiftwidth=2 expandtab)
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :hook (yaml-mode . (lambda () (setq tab-width 2))))

;; Markdown
(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :custom
  (markdown-command "pandoc"))

;; Nix
(use-package nix-mode
  :mode "\\.nix\\'")

;; Just (like vim-just)
(use-package just-mode
  :mode "[Jj]ustfile\\'")

;; Dockerfile
(use-package dockerfile-mode
  :mode "Dockerfile\\'")

;; Rust
(use-package rust-mode
  :mode "\\.rs\\'"
  :custom
  (rust-format-on-save t))

;; Go
(use-package go-mode
  :mode "\\.go\\'"
  :hook (before-save . gofmt-before-save))

;; TypeScript/JavaScript
(use-package typescript-mode
  :mode "\\.ts\\'"
  :custom
  (typescript-indent-level 2))

;; C/C++
(use-package cc-mode
  :straight nil
  :hook ((c-mode c++-mode) . (lambda ()
                                (setq c-basic-offset 4
                                      indent-tabs-mode nil))))

;; ============================================================
;; Code formatting (like vim-sleuth)
;; ============================================================
(use-package editorconfig
  :hook (after-init . editorconfig-mode))

(provide 'lang)
;;; lang.el ends here
