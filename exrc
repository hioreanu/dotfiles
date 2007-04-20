" $Id$
" NB: .exrc cannot contain blank lines
" http://www.saki.com.au/mirror/vi/bugs.php3
set autoindent
set noignorecase
set shell=/bin/sh
set showmode
set shiftwidth=4
set tabstop=4
set wrapmargin=8
"set flash
"set showmatch
set redraw
" Oracle does not come with a usable client program:
ab ora w! /tmp/ach.osql:%!oracle
ab edq :e! /tmp/ach.osql
" ignore F1 key
map [11~ :"
map #1 :"
"
" From Unix Power Tools, 3rd Edition:
"
" Read and write temp files to copy-paste between windows:
ab wa w! /tmp/ach.a.tmp
ab ra r /tmp/ach.a.tmp
ab wb w! /tmp/ach.b.tmp
ab rb r /tmp/ach.b.tmp
" Set 'exact' input mode for pasting exactly what is entered:
map!  :se noai wm=0a
" Set 'normal' input mode with usual autoindent and wrapmargin:
map!  :se ai wm=8a
" Read pasted text, clean up lines with fmt. Type CTRL-d when done:
map!  :r!fmt
"
" vim only:
" set et
" map <F5> :s.^//.. <CR> :noh <CR>
" map <F6> :s.^.//. <CR> :noh <CR>
" map <F7> :s/^\t// <CR> :noh <CR> gv
" map <F8> :s/^/\t/ <CR> :noh <CR> gv
"
map g G
map Y y$
"
map!  :stop
" stole these from Tom Christiansen:
" use ^I as meta char:
map 	 \
" center line
map \C ok:co.:s/./ /go80a :-1s;^;:s/;:s;$;//;"mdd@m:s/\(.\)./\1/g:s;^;:-1s/^/;"mdd@mjdd
" center c comment
" map \e I A yyp:s/.//go80a:-1s;^;:s/;:s;$;//;
" "mdd@m:s/\(.\)./\1/g:s;^;:-1s/^/;"mdd@mjdd
" (still working on it)
" escape comment block
map!  :unmap! 
" enter comment block
map \c	O/* * */k:map!  * A
" append to comment block
" map \o	:map!  *  A
" format C file
map \i :%!indent -kr -ts4:%!expand -4
" fmt mail message
" map \f 1G/^-- :1,!fmt
map \f :1,/^-- /!fmt
" fmt paragraph
map \q !}fmt
map K !}fmt -78 -c
" expand
" map \t :%!expand -4
map \t Ablurfl-vi-blah-blah:%!expand -4:%s/blurfl-vi-blah-blah$//
