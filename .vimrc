" Enable Pathogen (https://github.com/tpope/vim-pathogen)
execute pathogen#infect()

map <F5> :w<CR>:!./deploy.sh<CR>:redraw<CR>

""""""""""""""""""""""
" GLOBAL VIM TOGGLES "
""""""""""""""""""""""

" Line numbering and auto-indenting
set nu
set ai

" Tab stuff
set tabstop=4
set shiftwidth=4
set expandtab
set softtabstop=4

" Persistent undo
set undofile
set undodir=$HOME/.vimundo/

" 'g' flag for :%s on by default
set gdefault

" Use hlsearch by default
set hlsearch

"""""""""""""""""""
" CUSTOM SETTINGS "
"""""""""""""""""""

" Auto-complete shortcut -> phrase
iabbrev sout System.out.println();<Left><Left>

" Restore cursor upon re-opening a file
" (Note: has a bug where it doesn't save cursor index on top line of file)
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" Close Vim if NERDTree is the only window left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Keymappings
inoremap kk <ESC><Right>
inoremap jj <ESC><Right>
inoremap hh <ESC><Right>
nnoremap ' @
nnoremap <C-s> :w<CR>
nnoremap <C-p> :set paste!<CR>
nnoremap <C-z> :set spell!<CR>
map <C-f> :FixWhitespace<CR>
map <C-g> :GitGutterToggle<CR>
map <C-n> :NERDTreeToggle<CR>
map <C-b> :RainbowParenthesesToggle<CR>
map <C-l> :set nu!<CR>
map <C-h> :set hlsearch!<CR>
inoremap {{ {<CR>}<Esc>O

""""""""""""""""""""""""""""""
" LANGUAGE-SPECIFIC SETTINGS "
""""""""""""""""""""""""""""""

" Git commit message police
autocmd FileType gitcommit setlocal spell textwidth=72

" Python textwidth
autocmd FileType python set textwidth=79

" Use actual tabs in C
autocmd FileType c set expandtab!

" Go
autocmd FileType go set expandtab!
autocmd FileType go set textwidth=100
filetype off
filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim
set runtimepath+=$GOPATH/src/github.com/golang/lint/misc/vim
filetype plugin indent on
syntax on

" Ruby
autocmd FileType ruby set omnifunc=syntaxcomplete#Complete
autocmd Filetype ruby set tabstop=2
autocmd Filetype ruby set shiftwidth=2
autocmd Filetype ruby set softtabstop=2
" automate switching to another terminal to test out a script
autocmd FileType ruby map <F5> :w<CR>:!xdotool keydown super key Tab keyup super key Up KP_Enter <CR>:redraw<CR>

" Clojure (overtone)
autocmd FileType clojure RainbowParenthesesToggle

" Web
autocmd FileType html set tabstop=2
autocmd FileType html set shiftwidth=2
autocmd FileType html set softtabstop=2
autocmd FileType css set tabstop=2
autocmd FileType css set shiftwidth=2
autocmd FileType css set softtabstop=2
autocmd FileType xml set tabstop=2
autocmd FileType xml set shiftwidth=2
autocmd FileType xml set softtabstop=2

"""""""""""""
" GITGUTTER "
"""""""""""""

highlight clear SignColumn
highlight GitGutterAdd ctermfg=40 cterm=bold
highlight GitGutterChange ctermfg=178 cterm=bold
highlight GitGutterDelete ctermfg=124 cterm=bold

""""""""""""""""
" COLORSCHEMES "
""""""""""""""""

colorscheme lunarized
