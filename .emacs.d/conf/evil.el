;;; evil.el --- Evil mode & keybindings -*- lexical-binding: t; -*-

;; ============================================================
;; Evil (Vim emulation)
;; ============================================================
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-d-scroll t)
  (setq evil-want-Y-yank-to-eol t)    ; like Y y$
  (setq evil-undo-system 'undo-redo)
  (setq evil-search-module 'evil-search)
  (setq evil-ex-search-vim-style-regexp t)
  (setq evil-split-window-below t)    ; like set splitbelow
  (setq evil-vsplit-window-right t)   ; like set splitright
  (setq evil-shift-round t)           ; like set shiftround
  (setq evil-symbol-word-search t)
  :config
  (evil-mode 1))

;; Evil collection - integrates evil with many built-in modes
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Evil commentary (like nerdcommenter: gcc to toggle comment)
(use-package evil-commentary
  :after evil
  :hook (after-init . evil-commentary-mode))

;; Evil surround (like vim-surround: ys, ds, cs)
(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

;; Evil matchit (like vim-matchit: % to jump between matching pairs)
(use-package evil-matchit
  :after evil
  :config
  (global-evil-matchit-mode 1))

;; Evil snipe (like clever-f: enhanced f/t motions)
(use-package evil-snipe
  :after evil
  :custom
  (evil-snipe-scope 'whole-visible)
  (evil-snipe-repeat-scope 'whole-visible)
  :config
  (evil-snipe-mode 1)
  (evil-snipe-override-mode 1))

;; Evil visualstar (search selected text with *)
(use-package evil-visualstar
  :after evil
  :config
  (global-evil-visualstar-mode))

;; ============================================================
;; Leader key (like let mapleader = "\<space>")
;; ============================================================
(use-package general
  :after evil
  :config
  (general-evil-setup t)

  ;; Define SPC as leader in normal & visual states
  (general-create-definer my/leader
    :states '(normal visual insert motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Non-leader overrides in normal state
  (general-define-key
   :states 'normal

   ;; ---- Esc clears search highlight (like nnoremap <Esc> :let @/=''<CR>)
   "<escape>" (lambda () (interactive)
                (evil-ex-nohighlight)
                (evil-force-normal-state))

   ;; ---- n/N always forward/backward (like your nnoremap n 'Nn'[v:searchforward])
   "n" (lambda () (interactive)
         (evil-search-next)
         (evil-scroll-line-to-center (line-number-at-pos)))
   "N" (lambda () (interactive)
         (evil-search-previous)
         (evil-scroll-line-to-center (line-number-at-pos)))

   ;; ---- Y yank to EOL (like nnoremap Y y$) — already handled by evil-want-Y-yank-to-eol

   ;; ---- Move lines up/down (like S-Up/Down, uses drag-stuff)
   "S-<up>"   'drag-stuff-up
   "S-<down>" 'drag-stuff-down

   ;; ---- Buffer navigation (like <leader><Left/Right>)
   "C-<left>"  'previous-buffer
   "C-<right>" 'next-buffer

   ;; ---- Quick buffer list (like zl :ls<CR>:b)
   "zl" 'switch-to-buffer
   "z'" 'list-registers

   ;; ---- Folding (like zx)
   "za" 'hs-toggle-hiding
   "zR" 'hs-show-all
   "zM" 'hs-hide-all

   ;; ---- Visual shift reselect (like xnoremap < <gv / > >gv)
   "<" (lambda () (interactive)
         (evil-shift-left (region-beginning) (region-end))
         (evil-normal-state)
         (evil-visual-restore))
   ">" (lambda () (interactive)
         (evil-shift-right (region-beginning) (region-end))
         (evil-normal-state)
         (evil-visual-restore)))

  ;; ============================================================
  ;; Leader keybindings (like your <Space> leader in vimrc)
  ;; ============================================================
  (my/leader
    ;; ---- File operations
    "fs"  'save-buffer                  ; like <leader>fs :w
    "q"   'kill-current-buffer          ; like <leader>q :q
    "Q"   'kill-buffer-and-window       ; like <leader>Q :q!
    "bs"  'save-buffers-kill-terminal   ; like <leader><bs> :wqa

    ;; ---- Buffer navigation
    "<left>"  'previous-buffer          ; like <leader><Left>
    "<right>" 'next-buffer              ; like <leader><Right>

    ;; ---- Window management
    "wd"  'delete-window
    "wo"  'delete-other-windows         ; like C-x 1
    "ws"  'split-window-below           ; like C-x 2
    "wv"  'split-window-right           ; like C-x 3
    "wh"  'evil-window-left
    "wl"  'evil-window-right
    "wk"  'evil-window-up
    "wj"  'evil-window-down
    "w["  (lambda () (interactive) (evil-window-decrease-width 8))
    "w]"  (lambda () (interactive) (evil-window-increase-width 8))
    "w-"  (lambda () (interactive) (evil-window-decrease-height 2))
    "w="  (lambda () (interactive) (evil-window-increase-height 2))

    ;; ---- Search & Replace (like sa/sr/s/)
    "sr"  'my/query-replace-symbol-at-point
    "s/"  'query-replace
    "sp"  'consult-ripgrep
    "ss"  'consult-line

    ;; ---- Editing
    "j"   'evil-join                    ; join lines
    "W"   'delete-trailing-whitespace   ; like <leader>W :%s/\s\+$//
    "/"   'evil-commentary-line         ; like <leader>/ nerdcommenter toggle

    ;; ---- Files & Projects
    "ff"  'find-file                    ; like C-x C-f
    "fr"  'consult-recent-file
    "fp"  'project-find-file
    "fd"  'consult-fd
    "e"   'dired-jump                   ; like se :e <filedir>

    ;; ---- Git
    "gg"  'magit-status                 ; like vim-fugitive
    "gb"  'magit-blame                  ; like blamer.nvim
    "gd"  'magit-diff-buffer-file
    "gi"  'imenu                        ; like tagbar gi
    "gr"  'xref-find-references
    "gD"  'evil-goto-definition         ; like gD

    ;; ---- Misc
    "SPC" 'execute-extended-command     ; like M-x
    "bb"  'consult-buffer
    "bk"  'kill-current-buffer
    "TAB" 'consult-buffer
    ","   (lambda () (interactive)       ; like <leader>, append ;
            (evil-append-line 1)
            (insert ";")
            (evil-normal-state))
    "'"   (lambda () (interactive)       ; like <leader>' wrap in quotes
            (let ((bounds (bounds-of-thing-at-point 'word)))
              (when bounds
                (goto-char (cdr bounds))
                (insert "'")
                (goto-char (car bounds))
                (insert "'"))))))

(provide 'evil)
;;; evil.el ends here
