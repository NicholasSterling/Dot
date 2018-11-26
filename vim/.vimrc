
set modeline

set nocompatible       " Use Vim defaults (much better!)
set     tabstop=2      " Tabs indent 2, but use spaces.
set softtabstop=2      " Tabs indent 2, but use spaces.
set  shiftwidth=2      "
set          bs=2      " Allow backspacing over everything in insert mode.
set si                 " Always set smartindenting on.
set tw=90              " Always limit the width of text to 90.
set backup             " Keep a backup file.
set nu                 " Show line numbers.
set viminfo='20,\"50   " Read/write a .viminfo file;
                       "   don't store over 50 lines of registers.

set mouse=a

" Expand tabs to spaces, but not in Makefiles.
" No, do it always; the plugins will handle turning it off
" for Makefiles.
" let f = argv(0)
" let m = f =~ ".*Makefile.*"
" if m == 0
    set expandtab
" endif

set incsearch     " Do incremental searching.
set ignorecase    " Ignore case in searches,
set smartcase     "   unless pattern contains uppercase
set nowrapscan    " Don't wrap around on searches.

set tagbsearch    " Binary search the tags file first
set showmatch     " Show matching brace
set history=100
set hlsearch
set wildmenu

" set path=.,./../include/**,./../../include/**,/usr/include

" Always show status bar.
set laststatus=2

" Show row,column in status bar.
set ruler

" Keep 5 lines of context above/below cursor.
set scrolloff=5

" Mark wrapped lines with some obvious text.
set showbreak=________

" Don't use Ex mode, use Q for formatting
map Q gq

" This is the mkid stuff; seemed to replace "n", though.
"  :map su :source $HOME/.vim/such.vim<CR>
"  :map nn :n<CR>n

augroup cprog
  " Remove all cprog autocommands
  au!

  " When starting to edit a file:
  "   For *.c and *.h files set formatting of comments and set C-indenting on.
  "   For other files switch it off.
  "   Don't change the order, it's important that the line with * comes first.
  autocmd BufRead *       set formatoptions=tcql nocindent comments&
  autocmd BufRead *.c,*.h set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,://
augroup END

au FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

augroup gzip
  " Remove all gzip autocommands
  au!

  " Enable editing of gzipped files
  "      read:    set binary mode before reading the file
  "        uncompress text in buffer after reading
  "     write:    compress file after writing
  "    append:    uncompress file, append, compress file
  autocmd BufReadPre,FileReadPre    *.gz set bin
  autocmd BufReadPost,FileReadPost    *.gz '[,']!gunzip
  autocmd BufReadPost,FileReadPost    *.gz set nobin
  autocmd BufReadPost,FileReadPost    *.gz execute ":doautocmd BufReadPost " . %:r

  autocmd BufWritePost,FileWritePost    *.gz !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost    *.gz !gzip <afile>:r

  autocmd FileAppendPre            *.gz !gunzip <afile>
  autocmd FileAppendPre            *.gz !mv <afile>:r <afile>
  autocmd FileAppendPost        *.gz !mv <afile> <afile>:r
  autocmd FileAppendPost        *.gz !gzip <afile>:r
augroup END

" Only do this for Vim version 5.0 and later.
if version >= 500

syntax on

  highlight Normal guifg=black guibg=white
  highlight Cursor guibg=red guifg=bg
  highlight NonText guibg=grey80

  highlight clear Type
  highlight clear Statement
  highlight clear PreProc
  highlight clear Constant

  highlight Constant term=bold gui=NONE guifg=DarkGreen guibg=LightYellow
  highlight Special gui=NONE guibg=grey95
  highlight PreProc term=NONE gui=NONE
  highlight PreCondit term=inverse gui=inverse
  highlight Comment term=NONE guifg=DarkMagenta
  highlight link SpecialChar Constant

  highlight LineNr term=inverse ctermfg=Yellow ctermbg=Black

endif

" Enable handlers for file types.
filetype indent on
filetype plugin on
" filetype indent plugin on  " is this the same thing?

ab _S //////// STATIC ///////////////////////////////////////////////////////////////
ab _I //////// INSTANCE /////////////////////////////////////////////////////////////
ab _main public static void main( String[] args ) {
ab _out System.out.println(
ab _err System.err.println(

" ,jd   = Add Javadoc method header after current line
" ,e    = Select current word and go to end (like e)
" ,trim = Remove trailing whitespace from all lines
" ,man  = Remove the overstrikes from man pages
" ,n    = Toggle line numbers
map ,jd   o/** * * @param* @return*/kkka
map ,e    viw
map ,trim :%s/  *$//
map ,man  :%s///g<cr>gg
map ,n    :set nu!<cr>

" VimTip 173: Switch between splits very fast (for multi-file editing)
" http://vim.sf.net/tips/tip.php?tip_id=173
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
map <C-H> <C-W>h<C-W>|
map <C-L> <C-W>l<C-W>|
map <C-=> <C-W>=

" To keep edit sessions from hanging when VPN dies...
" set dir=/home/ns/.vim

" To make the windowing system's clipboard vim's default yank/put buffer.
" DOES NOT SEEM TO WORK
" set clipboard=unnamed

" %% means 'this file's path'
cabbr <expr> %% expand('%:p:h:')

set ofu=syntaxcomplete#Complete

function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.')+1)      " from the start of the current
                                                  " line to one character right
                                                  " of the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash  = match(substr, '\/') != -1      " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction

" This is pretty annoying most of the time, so it's disabled.
" inoremap <tab> <c-r>=Smart_TabComplete()<CR>

highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
