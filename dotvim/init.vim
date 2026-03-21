scriptencoding utf-8

" ====== custom function ====== [[[1
function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ''
endfunction

function! s:ColorsDefault() abort
    hi User1 ctermbg=darkgrey ctermfg=red guibg=#414752 guifg=#ec5f66
    hi User2 ctermbg=darkgrey ctermfg=white guibg=#414752 guifg=#d9d9d9
    hi User3 ctermbg=darkgrey ctermfg=magenta guibg=#414752 guifg=#ae8abe
    hi User4 ctermbg=darkgrey ctermfg=cyan guibg=#414752 guifg=#0cb0ae
    hi User5 ctermbg=darkgrey ctermfg=green guibg=#414752 guifg=#358661
    hi User6 ctermbg=darkgrey ctermfg=yellow guibg=#414752 guifg=#d6bf55
    hi User7 ctermbg=darkgrey ctermfg=blue guibg=#414752 guifg=#4f92ec
    hi User8 ctermbg=240 ctermfg=yellow guifg=#cc7832
    hi User9 ctermbg=240 ctermfg=grey guifg=#c14782
    hi StatusLine ctermbg=darkgrey
    hi StatusLineNC term=reverse ctermbg=238
    hi CursorLine   term=NONE cterm=NONE guibg=#404b59
    hi CursorLineNr term=reverse ctermfg=cyan guifg=#20b0ae
    hi VertSplit ctermbg=grey guibg=#6f6e70
    hi Search term=reverse ctermfg=235 ctermbg=180 guifg=#282C34 guibg=#b48232
    hi LineNr term=NONE ctermfg=grey guifg=#5f5e60
endfunction

function! GetAbsFileDir()
    return expand('%:p:h') . '/'
endfunction

function! LastSearchCount() abort
    let l:cnt = searchcount(#{recompute: 1})
    if empty(l:cnt) || l:cnt.total ==# 0
        return ''
    endif
    if l:cnt.incomplete ==# 1 " timed out
        return printf(' {%s} [?/??] ', @/)
    elseif l:cnt.incomplete ==# 2 " max count exceeded
        if l:cnt.total > l:cnt.maxcount
            let l:fmt = l:cnt.current > l:cnt.maxcount ? ' {%s} [>%d/>%d] ' : ' {%s} [%d/>%d] '
            return printf(l:fmt, @/, l:cnt.current, l:cnt.total)
        else
            return printf(' {%s} [?/0] ', @/)
        endif
    endif
    return printf(' {%s} [%d/%d] ', @/, l:cnt.current, l:cnt.total)
endfunction

function! GoToDefRSplit()
    " let cwin = winnr()
    exe "normal! \<C-w>v"
    exe 'wincmd L | vertical resize -6'
    exe 'tag ' . expand('<cword>')
    " exe 'normal zt'
    " exec cwin . 'wincmd w'
    " silent! wincmd H
endfunction

function! TabMoveInPopup(direction)
    let l:colBaseIdx = col('.') - 1
    if ! l:colBaseIdx || getline('.')[l:colBaseIdx - 1] !~ '\k'
        return "\<TAB>"
    elseif 'p' == a:direction
        return "\<C-p>"
    else
        return "\<C-n>"
    endif
endfunction

if !exists('*SourceAllVimRc')
    function! SourceAllVimRc()
        let l:finls = ''
        exe 'wa'
        for file in ['/etc/vimrc', '/etc/vim/vimrc', '$HOME/.vimrc']
            if filereadable(expand(file))
                exe 'source' file
                let l:finls = l:finls.' '.file
            endif
        endfor
        exe 'noh'
        echo 'sourced files:' . l:finls
    endfunction
endif

" length = 6
let g:mdot_mstl_list = [ '', '', '', '', '', '' ]
function! SetStatusLineMiddlePart(str, idx)
    let l:item = get(g:mdot_mstl_list, a:idx, "NONE")
    if l:item ==# "NONE"
        call add(g:mdot_mstl_list, a:str)
    elseif l:item ==# ''
        let g:mdot_mstl_list[a:idx] = a:str
    else
        echohl 'index: ' . a:idx . ' is not empty!'
    endif

    let &statusline  = g:mdot_left_stl
    let &statusline .= join(g:mdot_mstl_list, "%9* ")
    let &statusline .= g:mdot_right_stl
endfunction

function! CheckAndSwitchColorScheme(scheme)
    try
        execute 'silent! colorscheme ' . a:scheme
        return 1
    catch /^Vim\%((\a\+)\)\=:E185/
        return 0
    endtry
endfunction
" ====== custom function ]]]1

" ====== options ====== [[[1
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
if !has('nvim')
    set termencoding=utf-8
endif

set fileformats=unix,dos,mac

if has('syntax')
    syntax on
endif

if has('multi_byte') && &encoding ==# 'utf-8'
    let t:isMultiByte = 1
else
    let t:isMultiByte = 0
endif

" filetype
filetype on                     " Load plugins according to detected filetype.
filetype plugin on              " Enable filetype plugins
filetype indent on              " load specific type indent file

" base
set nocompatible                " don't bother with vi compatibility
set autoread                    " reload files when changed on disk
set autowrite
set gdefault                    " substitute flag 'g' on
set confirm                     " processing ont save or read-only file, pop confirm
set shortmess=aoOTI
set magic                       " For regular expressions turn magic on
set title                       " change the terminal's title
set history=1000                " history : how many lines of history VIM has to remember
set scrolloff=3                 " movement keep x lines when scrolling
set noerrorbells
set visualbell t_vb=

set timeout           " for mappings
set timeoutlen=1000   " default value
set ttimeout          " for key codes
set ttimeoutlen=10    " unnoticeable small value

" set nobackup                    " do not keep a backup file
set nowritebackup

if has('nvim')
    let t:cacheVim = $HOME . '/.cache/nvim'
else
    let t:cacheVim = $HOME . '/.cache/vim'
endif

let t:undoDir = t:cacheVim . '/undo'
let t:swapDir = t:cacheVim . '/swap'
let t:bakDir = t:cacheVim . '/backup'
let t:vimInfoFile = t:cacheVim . '/viminfo'

" undo dir
if has('persistent_undo')
    let &undodir = t:undoDir
    if !isdirectory(&undodir)
        silent! call mkdir(&undodir, 'p')
    endif
    set undofile
endif

" swap dir
let &directory = t:swapDir
if !isdirectory(&directory)
    silent! call mkdir(&directory, 'p')
endif
set swapfile

" backup dir
let &backupdir = t:bakDir
if !isdirectory(&backupdir)
    silent! call mkdir(&backupdir, 'p')
endif

let &viminfo .= ',!'                    " save global variable
let &viminfo .= ',n' . t:vimInfoFile    " set <viminfo> file path

" --- show
set number                      " show line numbers
set ruler                       " show the current row and column
set showcmd                     " display incomplete commands
set showmode                    " display current modes
set showmatch                   " jump to matches when entering parentheses
set matchtime=1                 " tenths of a second to show the matching parenthesis
set cursorline
set splitright
set splitbelow
set ttyfast                     " Faster redrawing.
set list
set relativenumber
set background=dark

" indent
set autoindent
set cindent
set smartindent
set shiftround

set tabstop=4                   " table key width
set smarttab                    " at the beginning of line and section?

" search
set hlsearch                    " highlight searches
set incsearch                   " do incremental searching, search as you type
set ignorecase                  " !!! ignore case when searching
set smartcase                   " no ignorecase if Uppercase char present
set infercase

" select & complete
set selection=exclusive          " selection donnot contain the last word
set selectmode=mouse,key
if has('mouse')
    set mouse=a                       " use mouse anywher in buffer
endif

set completeopt=longest,menu            " coding complete with filetype check
" set clipboard^=unnamed,unnamedplus
set suffixes+=.a,.1,.class
set wildmenu                            " show a navigable menu for tab completion
set wildmode=longest,list,full
set wildignore=.git,.hg,.svn,__pycache__,*.pyc,*.o,*.out,*.class,*.jpg,*.jpeg,*.png,*.gif,*.zip,*build*,**/tmp/**,*.DS_Store,**/node_modules/**,**/bower_modules/**
set wildoptions=tagfile
set wildignorecase

if t:isMultiByte
    let &listchars = 'tab:»·,trail:•,extends:→,precedes:←,nbsp:±'
    let &fillchars = 'vert: ,stl: ,stlnc: ,diff: '
    if has('showbreak')
        let &showbreak = '⣿'
    endif
else
    let &listchars = 'tab:>-,trail:.,extends:>,precedes:<,nbsp:+'
    let &fillchars = 'vert: ,stlnc:#'
    if has('showbreak')
        let &showbreak = '->'
    endif
endif

" --- others
set backspace=indent,eol,start  " make that backspace key work the way it should
set whichwrap+=h,l,<,>,[,],~    " allow backspace and cursor crossline border
set report=0                    " commands to tell user which line modified
" set diffopt=filler,iwhite,internal,linematch:60,algorithm:patience
set diffopt+=vertical,context:3,foldcolumn:0
if &diffopt =~ 'internal'
    set diffopt+=indent-heuristic,algorithm:patience
endif

if has('folding')
    set foldenable
    set foldlevelstart=99
    set foldmethod=manual
endif

set langmenu=zh_CN.UTF-8
set helplang=en

set formatoptions=croqn2mB1
set sessionoptions=blank,buffers,curdir,folds,help,options,tabpages,winsize,slash,unix,resize

if &term =~ "xterm"
    " SecureCRT versions prior to 6.1.x do not support 4-digit DECSET
    "    let &t_ti = "\<Esc>[?1049h"
    "    let &t_te = "\<Esc>[?1049l"
    " Use 2-digit DECSET instead
    let &t_ti = "\<Esc>[?47h"
    let &t_te = "\<Esc>[?47l"
endif

if empty($TMUX)
    let &t_SI = "\<Esc>]50;CursorShape=1\x7\<Esc>[?2004h"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7\<Esc>[?2004l"
else
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
endif

if executable('rg')
    let &grepformat = '%f:%l:%c:%m'
    let &grepprg = 'rg --hidden --vimgrep --smart-case -- $*'
else
    let &grepprg = 'grep --binary-files=without-match -irn $*'
endif
" ====== options ]]]1


"  ====== color & theme ====== [[[1
set t_Co=256

hi MyTabSpace ctermfg=darkgrey
match MyTabSpace /\t\| /

" if CheckAndSwitchColorScheme('habamax') == 0
    " call CheckAndSwitchColorScheme('peachpuff')
" endif

" set mark column color
hi! link SignColumn   LineNr
hi! link ShowMarksHLl DiffAdd
hi! link ShowMarksHLu DiffChange

" === status line === [[[2
call s:ColorsDefault()

set laststatus=2   " Always show the status line - use 2 lines for the status bar
set cmdheight=1    " cmdline which under status line height, default = 1

let g:mdot_left_stl  = '%1*[%n] %*'
let g:mdot_left_stl .= '%2*%<%.70f %*'
let g:mdot_left_stl .= '%3*%y%m%r%H%W %*%9*'

let g:mdot_right_stl = '%='

try
    call searchcount()
    let g:mdot_right_stl .= '%#WarningMsg#%{v:hlsearch ? LastSearchCount() : ""}%*'
catch /.*/
endtry

let g:mdot_right_stl .= '%4* %{&ff}[%{&fenc!="" ? &fenc : &enc}%{&bomb ? ",BOM" : ""}] %*'
let g:mdot_right_stl .= '%5*sw:%{&sw}%{&et ? "." : "»"}ts:%{&ts} %*'
let g:mdot_right_stl .= '%6*%l/%L,%c%V %*'
let g:mdot_right_stl .= '%7*%p%% %*'
let g:mdot_right_stl .= '%#ErrorMsg#%{&paste ? " paste " : ""}%*'

" first run it to setup stl only
call SetStatusLineMiddlePart('', 0)

" === status line ]]]2
" ====== color & theme ]]]1


" ====== autocmd group vimrcEx ====== [[[1
augroup vimrcEx
    autocmd VimEnter * set shellredir=>
    " --- Open file at the last edit line
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"zvzz" | endif
    " --- Autoreload .vim
    au BufWritePost,FileWritePost *vimrc,*.vim nested if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif
    " --- Check if file changed when its window is focus, more eager than 'autoread'
    au FocusGained * checktime
    " --- Always keep user default color in stl
    au ColorScheme * call s:ColorsDefault()
    " au BufWinEnter * normal! zvzz
    " au CursorHold * if pumvisible() == 0 | pclose | endif
    " --- Highlight current line only on focused window
    au WinEnter,BufEnter,InsertLeave * if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif
    au WinLeave,BufLeave,InsertEnter * if &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal nocursorline | endif
    " --- These kind of files donnot set undofile
    au BufWritePre /tmp/*,COMMIT_EDITMSG,MERGE_MSG,*.tmp setlocal noundofile
    au BufRead,BufNew tmux*.conf setf tmux
    au BufRead,BufNew *.conf,*.config setf config
    au BufRead,BufNew *.log setf messages
    au FileType yaml set shiftwidth=2 expandtab
    au FileType lua set noexpandtab tabstop=4 softtabstop=0
    au FileType systemd setlocal commentstring=#\ %s
    au FileType crontab setlocal nobackup nowritebackup
    au FileType help if &buftype != 'quickfix' | wincmd L | vertical resize -10 | endif
augroup END
" ====== autocmd group vimrcEx ]]]1


" ====== maps bind ====== [[[1
let mapleader = "\<space>"

" === normal noremap ===
nnoremap <leader><space> :w<CR>
nnoremap <leader>q :wq<CR>
nnoremap <leader><bs> :wqa<CR>
nnoremap <leader>e :q!<CR>
nnoremap <C-a> ggVG
nnoremap zx @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>

" cancel highlight search word and clean screen
nnoremap <silent> <leader>s :let @/=''<CR>:diffupdate<CR>:syntax sync fromstart<CR>

" always goto backward search result
nnoremap <expr> n  'Nn'[v:searchforward]
" always goto forward search result
nnoremap <expr> N  'nN'[v:searchforward]

nnoremap g; g;zvzz
nnoremap g, g,zvzz

" Yank text to EOL
nnoremap <silent> Y y$

" range mapping (v:count1)
" move current line [count] up/down
nnoremap <S-Up>   :<C-u>exe 'move -' . (1 + v:count1)<CR>
nnoremap <S-Down> :<C-u>exe 'move +' . v:count1<CR>
" add [count] line(s) above/below the current line
nnoremap [\  :<C-u>put! =repeat(nr2char(10), v:count1)<CR>'[
nnoremap ]\  :<C-u>put  =repeat(nr2char(10), v:count1)<CR>
" add [count] space(s) behind cursor, and cursor move follow the word
nnoremap [<space> :<C-u>exe 'normal! i' . repeat(' ', v:count1)<CR>l
" add [count] space(s) after cursor, and cursor postion donnot change
nnoremap ]<space> my:<C-u>exe 'normal! a '<CR>`y

nnoremap <leader>-  :<C-u>exe v:count1 . 'bprevious'<CR>
nnoremap <leader>=  :<C-u>exe v:count1 . 'bnext'<CR>
nnoremap <silent>z[ :<C-u>exe v:count1 . 'cprevious'<CR>
nnoremap <silent>z] :<C-u>exe v:count1 . 'cnext'<CR>

nnoremap <leader><Up> yyP
nnoremap <leader><Down> yyp

nnoremap zl :ls<CR>:b
nnoremap z' :registers<CR>
nnoremap zm :marks<CR>:<C-u>'

nnoremap tn :tabnew<CR>
nnoremap tk :tabnext<CR>
nnoremap tj :tabprevious<CR>
nnoremap to :tabonly<CR>
nnoremap tc :tabclose<CR>

nnoremap sc "ayiw
nnoremap sv viw"ap
nnoremap sw "byiW
nnoremap so viW"bp
nnoremap s- vg_p

if &gdefault > 0
    nnoremap sa :%s/<C-R>a/
    nnoremap s/ :%s/<C-R>//
    nnoremap sr :%s/\<<C-R><C-W>\>/
else
    nnoremap sa :%s/<C-R>a//g<Left><Left>
    nnoremap s/ :%s/<C-R>///g<Left><Left>
    nnoremap sr :%s/\<<C-R><C-W>\>//g<Left><Left>
endif

nnoremap se :e <C-R>=GetAbsFileDir()<CR>
nnoremap st :tabnew <C-R>=GetAbsFileDir()<CR>
nnoremap sh :setlocal nosplitright<CR>:vsplit <C-R>=GetAbsFileDir()<CR>
nnoremap sl :setlocal splitright<CR>:vsplit <C-R>=GetAbsFileDir()<CR>
nnoremap sk :setlocal nosplitbelow<CR>:split <C-R>=GetAbsFileDir()<CR>
nnoremap sj :setlocal splitbelow<CR>:split <C-R>=GetAbsFileDir()<CR>

nnoremap <leader>g :CpGrep "" <C-R>=GetAbsFileDir()<CR><C-Left><Left><Left>

nnoremap <leader>[ :vertical resize -8<CR>
nnoremap <leader>] :vertical resize +8<CR>
nnoremap <leader>k :resize -2<CR>
nnoremap <leader>j :resize +2<CR>

nnoremap <leader>" viw<ESC>bi"<ESC>ea"<ESC>
nnoremap <leader>, mzA;<ESC>`z

nnoremap <leader>fr :call SourceAllVimRc()<CR>
" Search for word equal to each
nnoremap <leader>fd /\(\<\w\+\>\)\_s*\1<CR>
" Trim EOL trailing space
nnoremap <leader>W :%s/\s\+$//<CR>
nnoremap <leader>w :call GoToDefRSplit()<CR>

" Enter break line
nnoremap <leader><CR> i<CR><Esc>k$

nnoremap ss "*y
" Wrap the word with double quote
nnoremap <leader>" viw<ESC>bi"<ESC>ea"<ESC>
" Append a ';' after EOL
nnoremap <leader>; mzA;<ESC>`z

xnoremap <  <gv
xnoremap >  >gv

" === insert noremap ===
inoremap <C-d> <Esc>ddi
inoremap <C-z> <Esc>ui
inoremap <C-u> <C-G>u<C-U>
inoremap <C-k> <C-o>D

inoremap <C-b> <C-Left>
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

" === command noremap ===
" Complete absolute path of current file (before input the file)
cnoremap <C-t> <C-R>=GetAbsFileDir()<CR>

" === visual noremap ===
vnoremap <S-Up>   :move '<-2<CR>gv
vnoremap <S-Down> :move '>+<CR>gv
" use xclip to copy line(s) to system clipboard in visual mode
if executable('xclip')
    vnoremap <C-c> :silent w !xclip -selection clipboard<CR>
endif

vnoremap <leader><space> "*y
vnoremap su "*p
" ====== maps ]]]1


" ====== custom command ======
command! -nargs=+ -complete=file CpGrep execute 'silent grep! <args>' | copen 9 | redraw!


" source other vimrc
" let user2ndVim=$HOME . '/.vim/user2.vim'
" let plugVim=$HOME . '/.vim/autoload/plug.vim'
" if filereadable(user2ndVim) && filereadable(plugVim)
"     exe 'source' user2ndVim
" endif


" ======================================== user2.vim ===================================================
scriptencoding utf-8

let user_vim_dir = $HOME.(has('nvim') ?  '/.config/nvim' : (has('win32') ? '\vimfiles' : '/.vim'))

" let g:plug_shallow = 1
" let g:plug_pwindow = 'vertical leftbelow new'

" call plug#begin(user_vim_dir . '/plugged')

" Plug 'vim-airline/vim-airline'
" Plug 'preservim/nerdtree'
" Plug 'jistr/vim-nerdtree-tabs'
" Plug 'preservim/nerdcommenter'
" Plug 'markonm/traces.vim'
" Plug 'luochen1990/rainbow'
" Plug 'junegunn/vim-easy-align'
" Plug 'machakann/vim-highlightedyank'
" Plug 'tpope/vim-sleuth'
" Plug 'tpope/vim-fugitive'
" Plug 'airblade/vim-gitgutter'
" Plug 'mileszs/ack.vim'
" Plug 'rhysd/clever-f.vim'
" Plug 'vim-scripts/a.vim'
" Plug 'octol/vim-cpp-enhanced-highlight'
" Plug 'jiangmiao/auto-pairs'
" Plug 'joshdick/onedark.vim'
" Plug 'junegunn/fzf'

" if (v:version > 704)
"     Plug 'Yggdroot/indentLine'
"     Plug 'karb94/vim-smoothie'
" endif

" if (v:version > 801)
"     Plug 'APZelos/blamer.nvim'
" endif

" if executable('ctags')
"     Plug 'preservim/tagbar'
    " let is_tagbar_loaded = 1
" endif

" let g:mdot_lsp_plug = get(g:, 'mdot_lsp_plug', 'ale')

" if g:mdot_lsp_plug ==# 'coc'
    " let coc_dir = $HOME . '/.config/coc'
    " if isdirectory(coc_dir) && v:version > 801
        " Plug 'neoclide/coc.nvim', { 'branch': 'release' }
        let t:is_coc_loaded = 1
        let g:coc_disable_startup_warning = 1
"     endif
" elseif g:mdot_lsp_plug ==# 'ale'
   " Plug 'w0rp/ale'
" endif

" call plug#end()


" ====== airline ====== [[[1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_splits = 1

let g:airline#extensions#tabline#show_buffers = 1

let g:airline#extensions#tabline#alt_sep = 1
let g:airline#extensions#tabline#left_sep = ' '

let g:airline_disable_statusline = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#overflow_marker = '…'

let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s:'
" ====== airline ]]]1

" ====== onedark ======
" if empty($TMUX)
    " if has('nvim')
        " let $NVIM_TUI_ENABLE_TRUE_COLOR = 1
    " endif
    " if has('termguicolors')
        " set termguicolors
    " endif
" endif

" call CheckAndSwitchColorScheme('onedark')

" ====== blamer.nvim ====== [[[1
" let g:blamer_enabled = 1
let g:blamer_delay = 800
let g:blamer_date_format = '%y/%m/%d %H:%M'

" highlight Blamer guifg=lightgrey
" ====== blamer.nvim]]]1

" ====== nerdcommenter ======
let g:NERDSpaceDelims = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

" nnoremap <silent> <leader>/ <Plug>NERDCommenterInvert " vim8.2 cannot work?
nnoremap <silent> <leader>/ :call nerdcommenter#Comment('n', "Invert")<CR>
vnoremap <silent> <leader>/ :call nerdcommenter#Comment('n', "Invert")<CR>

" ====== nerdtree vim-nerdtree-tabs
let g:NERDTreeShowHidden = 1
let g:NERDTreeShowIcons = 0

let g:NERDTreeWinSize = min([24, winwidth(0) / 5])
let g:NERDTreeWinSizeMax = 40
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'

let g:nerdtree_tabs_autoclose = 1
let g:nerdtree_tabs_open_on_console_startup = 2

nnoremap <C-n> :NERDTreeTabsToggle<CR>
" Find file in tree, and cursor move to the file position in tree
nnoremap <leader>m :NERDTreeFind<CR>

" ====== rainbow
let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle

" ====== vim-highlightedyank
let g:highlightedyank_highlight_duration = 700

" ====== vim-oscyank
" nnoremap <leader>c :call OSCYankOperator<CR>
" nnoremap <leader>cc <leader>c_
" vnoremap <leader>c <Plug>OSCYankVisual

" ====== tagbar
" if exists('is_tagbar_loaded') > 0
let g:tagbar_width = max([30, winwidth(0) / 5])
let g:tagbar_compact = 2
let g:tagbar_indent = 1
let g:tagbar_iconchars = ['+', '-']
let g:tagbar_sort = 0
let g:tagbar_position = 'topleft vertical'
nnoremap <silent> gi :TagbarToggle<CR>

let t:mstl_tagbar = '%8*%{tagbar#currenttag("[%s] ","")}%{tagbar#currenttagtype("(%s) ", "")}%*'
call SetStatusLineMiddlePart(t:mstl_tagbar, 1)
" endif

" ====== indentLine ======
let g:indentLine_char_list = ['┃']
let g:indentLine_conceallevel = 2
let g:vim_json_conceal = 0
let g:indentLine_defaultGroup = 'SpecialKey'
" let g:indentLine_color_term = 222

" ====== easyalign ======
" Start interactive EasyAlign in visual mode (e.g. vipga)
xnoremap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nnoremap ga <Plug>(EasyAlign)


" ====== fzf ====== [[[1
" NOTE: must add this path, otherwise fzf cannot work
" let &runtimepath .= ',' . user_vim_dir . '/plugged/fzf/bin'

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
" let g:fzf_layout = { 'down': '~40%' }
let g:fzf_layout = { 'down': '40%' }

autocmd! FileType fzf
autocmd  FileType fzf set laststatus=0 noshowmode noruler
    \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.cache/fzf-history'


" [Buffers] 如果可能跳到已存在窗口
let g:fzf_buffers_jump = 0
" [[B]Commits] 自定义被'git log'使用的选项
" let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" [Tags] 定义用来产生tag的命令
let g:fzf_tags_command = 'ctags --c++-kinds=+px --fields=+aiKSz --extras=+q --links=no --exclude={.git/,.github/,build/} -R '
" [Commands] --expect expression for directly executing the command
let g:fzf_commands_expect = 'alt-enter,ctrl-x'

nnoremap <leader>f :FZF<CR>
" ====== fzf ====== ]]]1

" following settings must load coc

" if g:mdot_lsp_plug ==# 'ale'
    " ====== ale ====== [[[1
    let g:ale_sign_column_always = 0
    let g:ale_set_highlights = 0

    let g:ale_sign_error = '✗'
    let g:ale_sign_warning = '⚡'
    "在vim自带的状态栏中整合ale，airline也可以显示这些信息
    let g:ale_statusline_format = ['✗ %d', '⚡ %d', '✔ OK']

    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

    nnoremap asp <Plug>(ale_previous_wrap)
    nnoremap asn <Plug>(ale_next_wrap)

    "文件内容发生变化时不进行检查
    " let g:ale_lint_on_text_changed = 'never'
    "打开文件时不进行检查
    let g:ale_lint_on_enter = 0

    let g:ale_c_gcc_options              = '-Wall -Werror -O2 -std=c11'
    let g:ale_c_clang_options            = '-Wall -Werror -O2 -std=c11'
    let g:ale_c_cppcheck_options         = ''

    let g:ale_cpp_gcc_options            = '-Wall -Werror -O2 -std=c++17'
    let g:ale_cpp_clang_options          = '-Wall -Werror -O2 -std=c++17'
    let g:ale_cpp_cppcheck_options       = ''

    let g:ale_linters = {
                \   'c++': ['clang++'],
                \   'c': ['clang'],
                \   'python' : ['flake8']
                \}
    " ====== ale ]]]1
" endif


if ! exists('t:is_coc_loaded')
    inoremap <silent><TAB>   <C-R>=TabMoveInPopup('n')<CR>
    inoremap <silent><S-TAB> <C-R>=TabMoveInPopup('p')<CR>
    inoremap <silent><expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"

    finish
endif

" ====== coc.nvim ====== [[[1
" coc custom
augroup clangdEx
    au FileType javascript setlocal omnifunc=coc#refresh()
    au FileType cpp setlocal omnifunc=coc#refresh()
    au FileType c,cpp nnoremap <F4> :call ClangdSwitchSourceHeaderVSplit()<CR>
augroup END

let t:mstl_coc = '%1*%{coc#status()}%{get(b:, "coc_current_function", "")}%*'
call SetStatusLineMiddlePart(t:mstl_coc, 0)

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nnoremap <silent> g[ <Plug>(coc-diagnostic-prev)
nnoremap <silent> g] <Plug>(coc-diagnostic-next)

" GoTo code navigation
nnoremap <silent> <leader>gd <Plug>(coc-definition)
nnoremap <silent> <leader>gy <Plug>(coc-type-definition)
nnoremap <silent> <leader>gi <Plug>(coc-implementation)
nnoremap <silent> <leader>gr <Plug>(coc-references)

" Symbol renaming
nnoremap <leader>rn <Plug>(coc-rename)

nnoremap <silent><nowait> \a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent><nowait> \e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent><nowait> \c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> go  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> \s  :<C-u>CocList -I symbols<cr>
" Do default action for next item
nnoremap <silent><nowait> \j  :<C-u>CocNext<CR>
" Do default action for previous item
nnoremap <silent><nowait> \k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent><nowait> \p  :<C-u>CocListResume<CR>
" ====== coc.nvim ]]]1

" vim:fdm=marker:fmr=[[[,]]]
