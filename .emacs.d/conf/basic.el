;;; basic.el --- Basic settings -*- lexical-binding: t; -*-

;; ============================================================
;; Encoding
;; ============================================================
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)

;; ============================================================
;; Files & Backup
;; ============================================================
(setq auto-save-default t)
(setq auto-save-timeout 20)
(setq create-lockfiles nil)
(setq make-backup-files nil)          ; no backup files (like set nobackup)
(setq confirm-kill-processes nil)     ; don't ask to kill processes on exit
(setq confirm-nonexistent-file-or-buffer nil)

;; undo (persistent undo like set undofile)
(setq undo-limit 80000000)
(setq undo-strong-limit 120000000)
(setq undo-outer-limit 360000000)

;; Auto-revert (like set autoread)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

;; ============================================================
;; Display
;; ============================================================
(setq-default display-line-numbers 'relative)
(setq display-line-numbers-width 3)
(setq line-spacing 0.1)

;; Scrolloff (like set scrolloff=3)
(setq scroll-margin 3)
(setq scroll-conservatively 101)
(setq scroll-preserve-screen-position t)

;; Cursor
(setq-default cursor-type 'bar)
(blink-cursor-mode -1)

;; Split direction (like set splitright splitbelow)
(setq split-width-threshold 1)
(setq split-height-threshold nil)

;; Mouse (like set mouse=a)
(xterm-mouse-mode 1)

;; Misc display
(setq visible-bell t)                 ; like set visualbell
(setq echo-keystrokes 0.1)            ; like set showcmd
(setq ring-bell-function 'ignore)     ; no error bells
(setq truncate-lines t)               ; don't wrap lines
(setq truncate-partial-width-windows nil)

;; ============================================================
;; Indentation
;; ============================================================
(setq-default indent-tabs-mode nil)   ; use spaces
(setq-default tab-width 4)            ; like set tabstop=4
(setq standard-indent 4)
(electric-indent-mode 1)

;; ============================================================
;; Search (like set hlsearch incsearch ignorecase smartcase)
;; ============================================================
(setq search-highlight t)
(setq search-whitespace-regexp ".*?")
(setq isearch-lax-whitespace t)
(setq isearch-regexp-lax-whitespace nil)
(setq case-fold-search t)             ; like set ignorecase
(setq-default case-replace t)

;; ============================================================
;; Completion & Wildmenu (like set wildmenu wildmode)
;; ============================================================
(setq completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

;; ============================================================
;; Misc
;; ============================================================
(setq history-length 1000)            ; like set history=1000
(setq history-delete-duplicates t)
(savehist-mode 1)

(setq-default require-final-newline t)
(setq-default sentence-end-double-space nil)
(setq kill-ring-max 100)

;; Auto-pair brackets (like auto-pairs plugin)
(electric-pair-mode 1)

;; Show matching paren (like set showmatch)
(show-paren-mode 1)
(setq show-paren-delay 0)

;; Delete selection mode (replace selected text when typing)
(delete-selection-mode 1)

;; y/n instead of yes/no
(setq use-short-answers t)

(provide 'basic)
;;; basic.el ends here
