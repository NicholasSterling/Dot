" Vim
" An example for a gvimrc file.
" The commands in this are executed when the GUI is started.
" To use it, copy it to ~/.gvimrc

set lines=110
set columns=84
set number

" Make external commands work through a pipe instead of a pseudo-tty
"set noguipty

" set the X11 font to use
" set guifont=-misc-fixed-medium-r-normal--12-130-75-75-c-70-iso8859-1
" set guifont=-*-clean-medium-r-*-*-12-*-*-*-*-*-*-*
" set guifont=Monospace\ 7
" set guifont=6x12
" set guifont=Consolas\ 7
  set guifont=DejaVu\ Sans\ Mono\ 7
  nmap   <F12> :let &guifont = 'DejaVu Sans Mono 7'<CR>
  nmap <S-F12> :let &guifont = 'DejaVu Sans Mono 10'<CR>
" nmap <F12> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) - 1)', '')<CR>
" nmap <S-F12> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) + 1)', '')<CR>

" Make command line two lines high
" set ch=2

" Background color

  highlight Normal            guibg=lightyellow
  highlight NonText           guibg=grey80
  highlight Constant gui=NONE guibg=grey95
  highlight Special  gui=NONE guibg=grey95
  highlight Cursor            guibg=Green  guifg=NONE


" Only do this for Vim version 5.0 and later.
if version >= 500

  " I like highlighting strings inside C comments
  " let c_comment_strings=1

  " Hide the mouse pointer while typing
  set mousehide

  " GUI options:
  "  a = make VISUAL mode text available to other apps for pasting
  "  g = show inactive menu items in grey
  "  l = scrollbar on left
  "  m = show menubar
  set guioptions=agmtr

endif
