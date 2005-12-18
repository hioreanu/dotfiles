# $Id$

PS1='%(#.%B;%b.;) '
if [ -n "$WINDOW" ] ; then
	WINDOWINDICATOR="[$WINDOW]"
fi
RPS1="#%m%S${WINDOWINDICATOR}%s %*"

bindkey -me

# do not execute /etc/zlogout
setopt NO_GLOBAL_RCS
# don't need to use 'export'
setopt ALL_EXPORT
# if have bg jobs, must use C-d twice
# setopt CHECK_JOBS
# don't send HUP to bg jobs on exit
setopt NO_HUP
# don't hash, always look in $PATH
setopt NO_HASH_CMDS
# don't put duplicate lines in history
setopt HIST_IGNORE_DUPS
# don't put lines that begin with space in history
setopt HIST_IGNORE_SPACE
# allow interactive comments
setopt INTERACTIVE_COMMENTS
# always do jobs -l
setopt LONG_LIST_JOBS
# don't warn if /opt/*/bin matches nothing, return literal string
setopt NO_NOMATCH
# make 'echo -n' work correctly
setopt NO_PROMPT_CR
# all xterms use the same history buffer
# setopt SHARE_HISTORY

HISTSIZE=3000
HISTFILE=~/.zsh_history
SAVEHIST=3000
unset MAILCHECK

# /xc/doc/hardcopy/xterm/ctlseqs.PS.gz
if [ -t 1 ] ; then
	case $TERM in
		vt100|*xterm*|rxvt|cygwin)
			precmd() { print -Pn "\e]2;%m${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\a" } ;;
		sun-cmd)
			precmd() { print -Pn "\e]1%m${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\e\\" } ;;
	esac
fi

EDITOR=vi
VISUAL=$EDITOR
LESS="-f -M -e -g -i -X"
PAGER=less
CVS_RSH=ssh
CVSEDITOR=vi

[ -z "$CVSROOT" ] && CVSROOT="$HOME/CVSROOT"
[ -z "$PATH" ] && PATH="/bin:/usr/bin"
if [ -z "$MANPATH" ] ; then
	MANPATH=/opt/man:/usr/man:/usr/local/man:/usr/X11R6/man:
	MANPATH=$MANPATH:/usr/openwin/man:/usr/share/man:/opt/SUNWspro/man
fi

pathdel() {
	PATH=`echo "$PATH" | sed 's/:/\n/g' | fgrep -v -x "$1" | sed -e :a -e '$!N; s/\n/:/' -e ta`
}
pathadd() {
	[ -d $1 ] || return
	if echo "$PATH" | sed "s/:/\n/g" | fgrep -x "$1" > /dev/null 2>&1 ; then return ; fi
	case $2 in
		"prepend") PATH="$1:$PATH" ;;
		"append"|"") PATH="$PATH:$1" ;;
		*) echo "usage: pathadd <component> [ prepend | append ]"
	esac
}

pathdel '.'

for i in /opt/*/bin ; do pathadd $i "append" ; done
for i in /usr/local/*/bin ; do pathadd $i "prepend" ; done
pathadd /usr/local/bin "prepend"
pathadd /usr/ucb "append"
pathadd /usr/ccs/bin "append"
pathadd /usr/xpg4/bin "append"
pathdel /opt/bin
pathadd /opt/bin "prepend"
if [ "$UID" -eq "0" ] ; then
	pathadd /sbin "append"
	pathadd /usr/sbin "append"
	pathadd /usr/local/sbin "append"
	for i in /usr/local/*/sbin ; do pathadd $i "append" ; done
	for i in /opt/*/sbin ; do pathadd $i "append" ; done
	pathdel /opt/sbin
	pathadd /opt/sbin "prepend"
fi
pathdel "$HOME/bin"
pathadd "$HOME/bin" "prepend"

unhash -am '*'
alias jobs="builtin jobs -l"
alias jbos="builtin jobs -l"
alias wpd=pwd
alias pdw=pwd
alias maek=make
alias amke=make
alias amek=make
alias mkae=make
alias kilmoz='killall -9 netscape ; rm -f ~/.netscape/lock'
alias gdb='gdb -q'
if bc --version >/dev/null 2>&1; then alias bc='bc -q' ; fi
alias standby='xset dpms force standby'
alias nchars='awk "{print length()}"'
alias gv='gv -antialias -noresize'
alias h='head -n $(($LINES - 1))'
alias dt='date +%Y%m%dT%H%M%S'
alias ds='date +%Y%m%d'

case "`uname -s`" in
	Darwin)
		export JAVA_HOME=/usr
		if ps auxww | fgrep X11.app > /dev/null 2>&1 ; then
			export DISPLAY=:0.0
			pathadd /usr/X11R6/bin append
		fi
		;;
	CYGWIN*)
		alias open='cmd /c start'
		;;
	SunOS)
		if [ "$TERM" = "linux" ]
			then TERM=vt220
		elif [ "`uname -r | sed 's/\..*//'`" -gt 4 ] ; then
			if [ "$TERM" = "cygwin" ] ; then
				TERM=xtermc
			elif [ "$TERM" = "xterm-color" ] ; then
				TERM=xtermc
			fi
		fi
		;;
esac


randsort() {
	perl -e 'srand(time() ^ ($$ + ($$ << 15)));
	         print sort {rand() <=> rand()} <STDIN>;'
}
audioplay=mpg123
playm3u() {
	randsort < "$1" | while read i ; do "$audioplay" "$i" ; done
}
megs() {
	ls -la "$@" | awk '{x += $5} END { printf("%.2f\n", (x / 1048576)) }'
}
dirs() {
	# follows symlinks, prints dot-dirs
	ls -A "$@" | while read i ; do [ -d $i ] && echo $i ; done
}
recurse() { # DFS
	dirs | while read DIR ; do
		"$@"
		cd "$DIR"
		recurse "$@"
		cd ..
	done
}
empty() {
	ls -lag "$@" | awk '$5 == 0 {print $9}'
}
dirsizes() {
	du -s `dirs` \
	| sort -nr \
	| awk '{print $2}' \
	| xargs du -sh
}
timecommand() {
	clear 
	while true ; do 
		printf "\r%s" "`date +"%T"`"
		sleep 1
	done
}
texwc() {
	perl -pe 's/%.*//g; s/\\(begin|end){\w*}//g; s/\\\w*//g;' "$@" | wc -w
}
tcpgrep() {
	tcpdump -p -X -n -q -s 8192 dst port $1 or src port $1
}

if [ -d ~/nsmail ] ; then rm -rf ~/nsmail ; fi
if [ "$UID" = "0" ] ; then
	umask 022
else
	umask 077
fi

[ -e "$HOME/.zsh-local" ] && source "$HOME/.zsh-local"
