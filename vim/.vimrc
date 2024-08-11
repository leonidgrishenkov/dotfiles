" Basic vim config

syntax on
set number
set relativenumber


inoremap jf <Esc>
vnoremap jf <Esc>

noremap j h
noremap l j
noremap ; l

" Disable yank on delete operations
nnoremap d "_d
vnoremap d "_d
nnoremap D "_D
vnoremap D "_D

nnoremap x "_x
vnoremap x "_x
nnoremap X "_X
vnoremap X "_X

xnoremap p P

set clipboard=unnamedplus


set expandtab           " Use spaces instead of tabs
set tabstop=4           " Number of spaces tabs count for
set shiftwidth=4        " Number of spaces to use for autoindent
set softtabstop=4       " Number of spaces per Tab

