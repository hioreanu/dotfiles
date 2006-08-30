source ~/.exrc
source ~/.vim/plugins/supertab.vim
" set et
set ruler
set notitle
set clipboard=exclude:.*

map! <f1> <esc>

set nocompatible
set backspace=indent,eol,start
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" command-line mappings
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>

let xterm16_colormap = 'soft'
let xterm16bg_Normal = 'none'
let xterm16_brightness = 'med'

function COLORON()
	if &term =~ 'xterm'
		set t_Co=256
	endif
	if version <= 601
		color xterm16vim61
	else
		color xterm16
	endif
	syn on
endfunction

if &term =~ 'xterm'
	autocmd BufNewFile,BufReadPre,FileReadPre *.java call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.pl call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.pm call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.cgi call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.c call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.h call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.cc call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.cpp call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.sh call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.xml call COLORON()
	autocmd BufNewFile,BufReadPre,FileReadPre *.sql call COLORON()
endif

if &t_Co > 2
	syntax on
	set hlsearch
endif
filetype plugin indent on
syntax off

if has("win32")
	se guicursor=n:blinkoff0
	let xterm16bg_Normal = '#002030'
	color xterm16
	highlight Cursor guibg=gray70
	if has("gui_running")
		let &guifont="Lucida_Console:h14:cANSI"
	endif
	behave mswin
	source $VIMRUNTIME/mswin.vim
endif
