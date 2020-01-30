filetype plugin indent on

" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" add plugins

" linting
Plug 'dense-analysis/ale'

" clojure
Plug 'tpope/vim-fireplace'
nnoremap <leader>cjsr :CljEval (cider.piggieback/cljs-repl (figwheel-sidecar.repl-api/repl-env))
Plug 'guns/vim-clojure-static'
Plug 'guns/vim-clojure-highlight'
Plug 'venantius/vim-cljfmt'
Plug 'kien/rainbow_parentheses.vim'
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces

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

" coc.nvim =========================================================
" if hidden is not set, TextEdit might fail.
set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" always show signcolumns
set signcolumn=yes

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
" nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
" nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
" nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
" nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
" nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
" nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
" nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
" nnoremap <silent> <space>p  :<C-u>CocListResume<CR><Paste>

" coc.nvim =========================================================

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
