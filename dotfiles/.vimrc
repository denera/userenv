set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
call plug#begin()

" ----- Making Vim look good ------------------------------------------
Plug 'arzg/vim-colors-xcode'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" ----- Vim as a programmer's text editor -----------------------------
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/syntastic'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-easytags'
Plug 'majutsushi/tagbar'
Plug 'kien/ctrlp.vim'
Plug 'Raimondi/delimitMate'
Plug 'ntpeters/vim-better-whitespace'
Plug 'Yggdroot/indentLine'

" ----- Working with Git ----------------------------------------------
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" ---- Language Servers -----------------------------------------------
Plug 'neoclide/coc.nvim', { 'branch': 'release' }

" All of your Plugins must be added before the following line
call plug#end()
filetype plugin indent on    " required

" ---- General settings -----------------------------------------------
set encoding=UTF-8
set backspace=indent,eol,start
set ruler
set number
set showcmd
set incsearch
set hlsearch
set mouse=a

" ----- arzg/vim-colors-xcode -----------------------------------------
syntax enable
silent! colorscheme xcodewwdc

" ----- bling/vim-airline ---------------------------------------------
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline_detect_paste=1
let g:airline#extensions#tabline#enabled = 1

" ----- jistr/vim-nerdtree-tabs ---------------------------------------
" Open/close NERDTree Tabs with \t
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
" To have NERDTree always open on startup
let g:nerdtree_tabs_open_on_console_startup = 0

" ----- Xuyuanp/nerdtree-git-plugin -----------------------------------
let NERDTreeMinimalUI = 1
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
let g:NERDTreeGitStatusIndicatorMapCustom = {
  \ 'Modified'  :'✹',
  \ 'Staged'    :'✚',
  \ 'Untracked' :'✭',
  \ 'Renamed'   :'➜',
  \ 'Unmerged'  :'═',
  \ 'Deleted'   :'✖',
  \ 'Dirty'     :'✗',
  \ 'Ignored'   :'☒',
  \ 'Clean'     :'✔︎',
  \ 'Unknown'   :'?',
  \ }
let g:NERDTreeGitStatusUseNerdFonts = 1
let g:NERDTreeGitStatusShowIgnored = 1
let g:NERDTreeGitStatusShowClean = 1

" ----- vim-syntastic/syntastic ---------------------------------------
let g:syntastic_error_symbol = '✘'
let g:syntastic_warning_symbol = "▲"
augroup mySyntastic
  au!
  au FileType tex let b:syntastic_mode = "passive"
augroup END

" ----- xolox/vim-easytags --------------------------------------------
" Where to look for tags files
set tags=./tags;,~/.vimtags
" Sensible defaults
let g:easytags_events = ['BufReadPost', 'BufWritePost']
let g:easytags_async = 1
let g:easytags_dynamic_files = 2
let g:easytags_resolve_links = 1
let g:easytags_suppress_ctags_warning = 1

" ----- majutsushi/tagbar ---------------------------------------------
" Open/close tagbar with \b
nmap <silent> <leader>b :TagbarToggle<CR>
" Uncomment to open tagbar automatically whenever possible
"autocmd BufEnter * nested :call tagbar#autoopen(0)

" ----- Yggdroot/indentLine -------------------------------------------
let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" ----- airblade/vim-gitgutter ----------------------------------------
" Required after having changed the colorscheme
hi clear SignColumn
" In vim-airline, only display "hunks" if the diff is non-zero
let g:airline#extensions#hunks#non_zero_only = 1

" ----- Raimondi/delimitMate ------------------------------------------
let delimitMate_expand_cr = 1
augroup mydelimitMate
  au!
  au FileType markdown let b:delimitMate_nesting_quotes = ["`"]
  au FileType tex let b:delimitMate_quotes = ""
  au FileType tex let b:delimitMate_matchpairs = "(:),[:],{:},`:'"
  au FileType python let b:delimitMate_nesting_quotes = ['"', "'"]
augroup END

" ---- neoclide/coc.nvim ----------------------------------------------
function! CocCurrentFunction()
  return get(b:, 'coc_current_function', '')
endfunction

let g:coc_disable_startup_warning = 1
let g:coc_global_config="$HOME/.config/nvim/coc-settings.json"
let g:coc_global_extensions = [
  \ 'coc-clangd',
  \ 'coc-python',
  \ 'coc-json',
  \ 'coc-git',
  \ 'coc-lists',
  \ 'coc-pairs',
  \ 'coc-snippets',
  \ 'coc-yank'
  \ ]
