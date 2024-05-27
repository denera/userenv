" Plugins ----------------------------------------------------------------- {{{
call plug#begin()

    " Sensible defaults
    Plug 'tpope/vim-sensible'

    " Support for various languages
    Plug 'sheerun/vim-polyglot'

    " Code Completion
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Colorschemes
    Plug 'navarasu/onedark.nvim'

    " Status line
    Plug 'itchyny/lightline.vim'

    " Smooth scrolling
    Plug 'yonchu/accelerated-smooth-scroll'

    " Navigate files easily
    Plug 'lokaltog/vim-easymotion'

    " Change surrounding characters
    Plug 'tpope/vim-surround'

    " Git support
    Plug 'tpope/vim-fugitive'

    " Github support
    Plug 'tpope/vim-rhubarb'

    " Allow repetition of plugin mappings
    Plug 'tpope/vim-repeat'

    " Commenting plugin
    Plug 'tpope/vim-commentary'

    " Session management
    Plug 'tpope/vim-obsession'

    " Netrw enhancement
    Plug 'tpope/vim-vinegar'

    " Handy bracket mappings
    Plug 'tpope/vim-unimpaired'

    " Fuzzy finder
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'

    " Display diff symbols
    Plug 'mhinz/vim-signify'

	" FileTree navigator
	Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggleVCS' }

        " Tab management for Nerdtree
        Plug 'jistr/vim-nerdtree-tabs'

        " Nerdtree plugin to show git status
        Plug 'Xuyuanp/nerdtree-git-plugin'

        " Add developer icons
        Plug 'ryanoasis/vim-devicons'

    " Automatically set cwd
    Plug 'airblade/vim-rooter'

    " View LSP Symbols
    Plug 'liuchengxu/vista.vim'

    " Semantic Highlighting for C/C++
    Plug 'jackguo380/vim-lsp-cxx-highlight'

    " Pulse the line after a search
    Plug 'danilamihailov/beacon.nvim'

    " Highlight word under the cursor
    Plug 'RRethy/vim-illuminate'

    " Distraction free writing
    Plug 'junegunn/goyo.vim'

    " Limelight
    Plug 'junegunn/limelight.vim'

    " Org-mode for vim
    Plug 'jceb/vim-orgmode'

    " Undo tree
    Plug 'sjl/gundo.vim'

    " Add common snippets
    Plug 'honza/vim-snippets'

call plug#end()
" }}}

" Options ----------------------------------------------------------------- {{{

" Default to dark color groups for backgrounds
set background=dark

let g:onedark_config = {
    \ 'style': 'warmer',
\}
colorscheme onedark

syntax enable

" Show line numbers
set number

" Give more space for displaying messages
set cmdheight=2

" Limit width to 80
set textwidth=100

" Horizontal splits open below
set splitbelow

" Vertical splits open to the right
set splitright

" Number of visual spaces per TAB
set tabstop=4

" Number of spaces in tab when editing
set softtabstop=4

" Number of columns text is indented with when reindenting using << or >>
set shiftwidth=4

" Highlight matching [{()}]
set showmatch

" Use spaces instead of tabs
set expandtab

" Disable wrapping by default
set nowrap

" Open most folds by default
set foldlevelstart=10

" 10 nested fold max
set foldnestmax=10

" Fold based on indent level
set foldmethod=indent

" Required for operations modifying multiple buffers like rename.
set hidden

" Redraw only when we need to
set lazyredraw

" Disable swap files
set noswapfile

" Use file names as title of terminal while editing
set title

" Hide mouse when typing
set mousehide

" No alarms and no surprises
set noerrorbells visualbell t_vb=

" Yank and paste with the system clipboard
set clipboard=unnamed

" Apply substitutions globally by default
set gdefault

" Ignore certain file types and directories from fuzzy finding
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.pdf,*.psd,*.hdr
set wildignore+=node_modules/*,target/*

" Make searches case insensitive
set ignorecase

" Override ignorecase option if search contains uppercase characters
set smartcase

" Some servers have issues with backup files
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Wrapping options
set formatoptions=tc " Wrap text and comments using textwidth
set formatoptions+=r " Continue comments when pressing ENTER in insert mode
set formatoptions+=q " Enable formatting of comments with qg
set formatoptions+=n " Detect lists for formatting
set formatoptions+=b " Auto-wrap in insert mode, and do not wrap old long lines

" Always show the signcolumn
set signcolumn=yes

" Enable 24-bit RGB color in the TUI
set termguicolors

" }}}

" Settings ---------------------------------------------------------------- {{{

if exists('g:fvim_loaded')
    nnoremap <leader>TF :FVimToggleFullScreen<cr>
endif

" C++ format on save
autocmd BufWritePost *.cpp :call CocAction('format')

" Use fold markers when editing vim files
au BufNewFile,BufRead *.vim set foldmethod=marker

" Properly match comments in json files
autocmd FileType json syntax match Comment +\/\/.\+$+

" Toggle relativenumber in insert mode and regular line numbers in normal mode
autocmd InsertEnter * silent! :set norelativenumber
autocmd InsertLeave,BufNewFile,VimEnter * silent! :set relativenumber

" Set grep program to ripgrep if available and set the format
if executable('rg')
    set grepprg=rg\ --no-heading\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

augroup MyCursorLineGroup
    autocmd!
    au WinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup end

" }}}

" Plugins ----------------------------------------------------------------- {{{
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'cocstatus', 'currentfunction', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'cocstatus': 'coc#status',
      \   'currentfunction': 'CocCurrentFunction'
      \ },
      \ }

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

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

let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_smart_startup_focus=1
let g:nerdtree_tabs_autoclose=1
let g:nerdtree_tabs_autofind=1

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

let g:coc_global_config="$HOME/.config/nvim/coc-settings.json"
let g:coc_global_extensions = [
    \ 'coc-clangd',
    \ 'coc-pyright',
    \ 'coc-json',
    \ 'coc-git',
    \ 'coc-lists',
    \ 'coc-pairs',
    \ 'coc-snippets',
    \ 'coc-yank'
    \ ]

let g:python3_host_prog = '/usr/bin/python3'
let g:gundo_prefer_python3 = 1
