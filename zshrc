# $Id$

# PS1="%m%# "
PS1='%(#.%B;%b.;) '
if [ -n "$WINDOW" ] ; then
	WINDOWINDICATOR="[$WINDOW]"
fi
RPS1="#%m%S${WINDOWINDICATOR}%s %*"

bindkey -me
# bindkey '\e' vi-cmd-mode

#if [ ! -z "$ZSH_VERSION" -a \
#	"`echo $ZSH_VERSION | sed 's/\..*//'`" = 3 -a \
#	"`echo $ZSH_VERSION | sed 's/.*\.//'`" -lt  -a \

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
if [[ -t 1 ]] ; then
	case $TERM in
		vt100|*xterm*|rxvt|cygwin)
			precmd() { print -Pn "\e]2;%m${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\a" } ;;
		sun-cmd)
			precmd() { print -Pn "\e]1%m${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\e\\" } ;;
	esac
fi

if [ "`uname -s`" = "SunOS" ] ; then
	if [ "$TERM" = "linux" ] ; then TERM=vt220 ; fi
	if [ "`uname -r | sed 's/\..*//'`" -gt 4 ] ; then
		if [ "$TERM" = "cygwin" ] ; then TERM=xtermc ; fi
		if [ "$TERM" = "xterm-color" ] ; then TERM=xtermc ; fi
	fi
fi

EDITOR=vi
VISUAL=$EDITOR
LESS="-f -M -e -g -i -X"
PAGER=less
CVS_RSH=ssh
CVSEDITOR=vi

if [ -z "$CVSROOT" ] ; then
	CVSROOT="$HOME/CVSROOT"
fi

if [ -z $PATH ] ; then
	PATH="/bin:/usr/bin"
fi

if [ -z $MANPATH ] ; then
	MANPATH=/opt/man:/usr/man:/usr/local/man:/usr/X11R6/man:
	MANPATH=$MANPATH:/usr/openwin/man:/usr/share/man:/opt/SUNWspro/man
fi

pathdel() {
	PATH=`echo $PATH | sed -e "s@\(.*\)\(\:\)$1\(\:\)\(.*\)@\1:\4@g" \
	                       -e "s@^$1:@@" -e "s@:$1"'$@@'`
}
pathadd() {
	if echo $PATH | fgrep "$1" > /dev/null 2>&1 ; then
		:
	else
		if [ -d $1 ] ; then 
			case $2 in
				"append") PATH=$PATH:$1 ;;
				"prepend") PATH=$1:$PATH ;;
				*) echo fixme
			esac
		fi
	fi
}

pathdel '\.'

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

if [ "`uname -s`" = "Darwin" ] ; then
	export JAVA_HOME=/usr
	if ps auxww | fgrep X11.app > /dev/null 2>&1 ; then
		export DISPLAY=:0.0
		pathadd /usr/X11R6/bin append
	fi
fi

unhash -am '*'
alias jobs="builtin jobs -l"
alias jbos="builtin jobs -l"
alias wpd=pwd
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

randsort() {
	perl -e 'srand(time() ^ ($$ + ($$ << 15)));
	         print sort {rand() <=> rand()} <STDIN>;'
}
ssh2pubkeysetup() {
	ssh "$@" \
		'mkdir $HOME/.ssh2 ; echo Key ach0.ssh.com-dss > $HOME/.ssh2/authorization ; cat > $HOME/.ssh2/ach0.ssh.com-dss' \
		< $HOME/.ssh2/ach0.ssh.com-dss
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
zero() {
	dd if=/dev/zero "of=$1" bs=1 count=`ls -l "$1" | awk '{print $5}'`
}

if [ -d ~/nsmail ] ; then rm -rf ~/nsmail ; fi
if [ "$UID" = "0" ] ; then
	umask 022
else
	umask 077
fi

if [ -e "$HOME/.zsh-local" ] ; then source "$HOME/.zsh-local" ; fi
