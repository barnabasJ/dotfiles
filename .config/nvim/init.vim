filetype plugin indent on

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" add plugins

Plug 'christoomey/vim-tmux-navigator'

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-projectionist'

Plug 'tpope/vim-dispatch'
Plug 'radenling/vim-dispatch-neovim'

" Multi-Language Support
Plug 'sheerun/vim-polyglot'

" Automaticly set working directory to project root
Plug 'airblade/vim-rooter'

" Completions + LanguageServer
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Tagbar
Plug 'majutsushi/tagbar'
nnoremap <F8> :TagbarToggle<CR>

" UI
Plug 'flazz/vim-colorschemes'

call plug#end()


" Tab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
    

" Set leader
let mapleader=" "
let maplocalleader="\\"

" Build shortcuts 
nnoremap <leader>m :w<Cr>:Make<CR>

""" UI Tweaks =========================
set number           " show number for current line
set relativenumber   " show relative number for other lines

" Clear the search buffer when hitting return
nnoremap <cr> :nohlsearch<cr>

" Disable Help Button
map <F1> :echo<CR>

""""" BACKUP / TMP FILES
" taken from
" http://stackoverflow.com/questions/4331776/change-vim-swap-backup-undo-file-name
" Save your backups to a less annoying place than the current directory.
" If you have .vim-backup in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/backup or . if all else fails.
if isdirectory($HOME . '/.local/share/nvim/backup') == 0
  :silent !mkdir -p ~/.local/share/nvim/backup >/dev/null 2>&1
endif
set backupdir-=.
set backupdir+=.
set backupdir-=~/
set backupdir^=~/.local/share/nvim/backup
set backupdir^=./.vim-backup/
set backup

" Save your swp files to a less annoying place than the current directory.
" If you have .vim-swap in the current directory, it'll use that.
" Otherwise it saves it to ~/.vim/swap, ~/tmp or .
if isdirectory($HOME . '/.local/share/nvim/swap') == 0
  :silent !mkdir -p ~/.local/share/nvim/swap >/dev/null 2>&1
endif
set directory=./.vim-swap//
set directory+=~/.local/share/nvim/swap//
set directory+=~/tmp//
set directory+=.

" viminfo stores the the state of your previous editing session
set viminfo+=n~/.local/share/nvim/viminfo

if exists("+undofile")
  " undofile - This allows you to use undos after exiting and restarting
  " This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
  " :help undo-persistence
  " This is only present in 7.3+
  if isdirectory($HOME . '/.local/share/nvim/undo') == 0
    :silent !mkdir -p ~/.local/share/nvim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.local/share/nvim/undo//
  set undofile
endif

" Include subfolders in path for find
set path +=**

" UI
colorscheme molokai

" move lines up or down
:nnoremap - ddp
:nnoremap _ ddkP

" Upcase current word
:inoremap <C-u> <Esc>gUiWi

" Downcase current word
:inoremap <C-l> <esc>guiwi

" edit vimrc
:nnoremap <leader>ev :vsplit $MYVIMRC<Cr>

" source vimrc
:nnoremap <leader>sv :source $MYVIMRC<Cr>

" quote word
:nnoremap <leader>" ciw""<Esc>Pl
:nnoremap <leader>' ciw''<Esc>Pl

" Terminal
if has('nvim')
    tnoremap <Esc> <C-\><C-n>
    tnoremap <C-v><Esc> <Esc>
    highlight! TermCursor guibg=red guifg=white ctermbg=1 ctermfg=15
    highlight! TermCursorNC guibg=red guifg=white ctermbg=1 ctermfg=15
endif

if has('nvim') && executable('nvr')
    let $VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
endif
