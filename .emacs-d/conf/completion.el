;;; completion.el --- Search & Completion framework -*- lexical-binding: t; -*-

;; ============================================================
;; Vertico (minibuffer completion, like fzf + wildmenu)
;; ============================================================
(use-package vertico
  :hook (after-init . vertico-mode)
  :custom
  (vertico-cycle t)
  (vertico-count 15)
  (vertico-resize t))

;; Orderless (flexible matching, like fzf's fuzzy matching)
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia (annotations in minibuffer, like fzf preview)
(use-package marginalia
  :hook (after-init . marginalia-mode)
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle)))

;; Consult (search & navigation commands, replaces fzf)
(use-package consult
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ;; C-x bindings
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ;; M-g bindings (goto-map)
         ("M-g g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g i" . consult-imenu)
         ;; M-s bindings (search-map)
         ("M-s g" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi))
  :custom
  (consult-narrow-key "<")
  (consult-line-numbers-width 1)
  (consult-async-min-input 2)
  (consult-async-refresh-delay 0.15)
  (consult-async-input-throttle 0.2)
  (consult-async-input-debounce 0.1)
  ;; Use ripgrep for grep
  (consult-grep-args "rg --null --line-buffered --color=always --max-columns=500 --no-heading --line-number -S"))

;; Embark (context actions, like fzf's ctrl-t/ctrl-x/ctrl-v)
(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; Corfu (in-buffer completion, like vim's completeopt)
(use-package corfu
  :hook (after-init . global-corfu-mode)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match 'separator)
  (corfu-preview-current 'insert)
  (corfu-preselect 'prompt))

;; Cape (completion-at-point extensions)
(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;; Wgrep (editable grep results)
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t))

(provide 'completion)
;;; completion.el ends here
