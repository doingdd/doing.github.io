set autoindent
set incsearch
set expandtab
set softtabstop=4
set ts=4
"set cursorline

" Nerd Tree
" set F3 to turnon nerdtree
 map <F3> :NERDTreeToggle<CR>
 let NERDChristmasTree=0
 let NERDTreeWinSize=30
 let NERDTreeChDirMode=2
 let NERDTreeIgnore=['\~$', '\.pyc$', '\.swp$']
 let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$',  '\~$']
 let NERDTreeShowBookmarks=1
 let NERDTreeWinPos = "right"
  
"
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
" nerdcommenter
  let NERDSpaceDelims=1
" nmap <D-/> :NERDComToggleComment<cr>
  let NERDCompactSexyComs=1


"------------------
"" Useful Functions
"------------------                                                               
"" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

hi comment ctermfg=6
