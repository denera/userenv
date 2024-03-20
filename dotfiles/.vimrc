" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" Install plugins {{
call plug#begin('~/.vim/plugged')

Plug 'sheerun/vimrc'
Plug 'sheerun/vim-polyglot'
Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'preservim/tagbar'
Plug 'ayu-theme/ayu-vim'
Plug 'Yggdroot/indentLine'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()
" }}

" Choose color scheme {{
set termguicolors
let ayucolor="mirage"
colorscheme ayu
" }}

" Configure indent Line {{
let g:indentLine_char = '|'
let g:indentLine_first_char = '|'
let g:indentLine_showFirstIndentLevel = 1
let g:indentLine_setColors = 0
" }}

" Set key maps  {{
let mapleader = "\<Space>"
nmap <F8> :TagbarToggle<CR>
nnoremap <Leader>f :NERDTreeToggle<Enter>
" }}

" Start NERDTree by default  {{
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
" }}

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree  {{
autocmd BufEnter * if winnr() == winnr('h') && bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif
" }}

" Close the tab if NERDTree is the only window remaining in it  {{
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" }}

" Exit Vim if NERDTree is the only window remaining in the only tab  {{
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
" }}

" Git status symbols  {{
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
" }}

" Dev icons  {{
set encoding=UTF-8
let g:WebDevIconsDisableDefaultFolderSymbolColorFromNERDTreeDir = 1
let g:WebDevIconsDisableDefaultFileSymbolColorFromNERDTreeFile = 1
let g:NERDTreeSyntaxEnabledExtensions = ['c', 'c++', 'cpp', 'cu', 'h', 'py', 'yaml', 'json', 'toml']
" }}
