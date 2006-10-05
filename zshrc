# $Id$

benchmark="no" # for optimizing startup time; requires GNU date
[ "$benchmark" = "yes" ] && zshstart=`date +%s%N`

hostname=`hostname`
# work around zsh versions not implementing UTF-8 string width calculations
esczshutf8() {
	s="$1"
	if [ -z "`echo "${s}" | tr -d '[:alnum:]'`" ] ; then
		echo "${s}"
		return 0
	else
		sz=$((`echo "${s}" | perl -CI -pe 's/.*/length()/e'` - 1))
		perl -CI -e "print 'X' x $sz, '%{', chr(010) x $sz, '${s}', '%}', chr(012);"
	fi
}
hostname_esc=`esczshutf8 "${hostname}"`
PS1='%(#.%B;%b.;) '
RPS1="#${hostname_esc}%S${WINDOWINDICATOR}%s %*"
if [ "$TERM" = "screen" ] ; then
	if [ -n "$WINDOW" ] ; then
		# XXX use escape codes instead
		SCREENHOST="$hostname"
		screen -X addacl :window: +x paste
		screen -X addacl :window: -x register
		screen -X register h "${hostname}
"
		screen -X register w "$WINDOW
"
	else
		stty -echo
		print -n "\e]83;paste w\a"
		read WINDOW
		print -n "\e]83;paste h\a"
		read SCREENHOST
		stty echo
		SCREENHOST=`esczshutf8 "${SCREENHOST}"`
	fi
	if [ "$SCREENHOST" = "$hostname" ] ; then
		RPS1="#${hostname_esc}%S${WINDOW}%s %*"
	else
		RPS1="#${hostname_esc}%S%U${SCREENHOST}%u${WINDOW}%s %*"
	fi
	precmd() { print -Pn "\ek${hostname}[${SCREENHOST} ${WINDOW}]%D{%H:%M:%S} - %n: %~\e\\" }
fi

bindkey -me

# do not execute /etc/zlogout
# GLOBAL_RCS introduced in zsh 3.1.6b; faster to check only first token
if [ "${ZSH_VERSION%%.*}" -ge 4 ] ; then setopt NO_GLOBAL_RCS ; fi
# don't need to use 'export'
setopt ALL_EXPORT
# if have bg jobs, must use C-d twice
# setopt CHECK_JOBS
# don't send HUP to bg jobs on exit
setopt NO_HUP
# hash pathname of command first time used
setopt HASH_CMDS
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
# do not overwrite partial output (no newline) with prompt
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
		*xterm*|rxvt|cygwin)
			precmd() {
				print -Pn "\e]2;${hostname}${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\a"
				print -Pn "\e]1;${hostname}\a"
			}
			screen() {
				iconname="${hostname}"
				while getopts :S: scropt ; do
					[ "$scropt" = "S" ] && iconname="${OPTARG} ${hostname}"
				done
				print -Pn "\e]1;\{${iconname}\}\a"
				command screen "$@"
			}
			;;
		sun-cmd)
			precmd() { print -Pn "\e]1%m${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\e\\" } ;;
	esac
	if [ "$TERM" = "screen" -o -n "$WINDOW" ] ; then
		precmd() { print -Pn "\ek${hostname}${WINDOWINDICATOR} %D{%H:%M:%S} - %n: %~\e\\" }
	fi
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

if [ "${${VERSION#zsh }%%.*}" = "2" ] ; then
	# zsh version 2 - cannot use variable substitution string manipulation
	newline="`echo ; echo`"
	pathdel() {
		PATH=`echo "$PATH" | tr : "${newline}" | fgrep -v -x "$1" | sed -e :a -e '$!N; s/\n/:/' -e ta`
	}
	inpath() {
		# zsh 2.5.03 bug: segfault if "return" called in func. called from func.
		(
		if echo "$PATH" | tr : "${newline}" | fgrep -x "$1" > /dev/null 2>&1
		then return 0
		else return 1
		fi
		)
	}
else
	pathdel() {
		# optimization: use zsh-specific feature to perform substitution
		# avoids process invocations - saves 0.50s shell startup time on laptop
		PATH=${(pj:\x3A:)${==${(ps:\x3A:)PATH}:#$1}}
	}
	inpath() {
		# optimization: use zsh-specific features to avoid additional processes
		# saves 0.30s shell startup time on laptop
		if [ "$PATH" != ${(pj:\x3A:)${==${(ps:\x3A:)PATH}:#$1}} ] ; then
			return 0
		else
			return 1
		fi
	}
fi

pathadd() {
	1=${1%/}
	[ -d "$1" ] || return
	inpath "$1"
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
if [ "$UID" -eq "0" -o \! -z "`/usr/bin/groups | fgrep wheel`" ] ; then
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

unalias -m '*'
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
alias cvsstat='cvs status 2>&1 | fgrep Status:'
alias sudosh='sudo /bin/sh -c "`fc -ln -1`"'
alias dt='date +%Y%m%dT%H%M%S'
alias ds='date +%Y%m%d'
alias ws=ds
if date --version > /dev/null 2>&1 ; then
	alias ws='date -d "now - `date +%u` days + 1 day" +%Y%m%d'
fi

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
		if [ "$TERM" = "linux" ] ; then
			TERM=vt220
		elif [ "$TERM" = "screen" ] ; then
			TERM=vt100
		elif [ "`uname -r | sed 's/\..*//'`" -gt 4 ] ; then
			if [ "$TERM" = "cygwin" ] ; then
				TERM=xtermc
			elif [ "$TERM" = "xterm-color" ] ; then
				TERM=xtermc
			fi
		fi
		;;
esac

loadsshagent() {
	# requires pgrep; so far works on boxes where this is used
	if [ -f "$HOME/.ssh/id_dsa.pub" -a -z "$SSH_AGENT_PID" ] ; then
		SSH_AGENT_PID="`pgrep -f ssh-agent`"
		if [ -z "$SSH_AGENT_PID" ] ; then
			eval `ssh-agent` > /dev/null 2>&1
		else
			SSH_AUTH_SOCK="`ls -t /tmp/ssh-*/agent.* | head -n 1`"
		fi
		export SSH_AGENT_PID SSH_AUTH_SOCK
	fi
}

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
	# umask 077
	umask 022
fi

[ -e "$HOME/.zsh-local" ] && source "$HOME/.zsh-local"

if [ "$benchmark" = "yes" ] ; then
	echo Startup time: $(((`date +%s%N` - $zshstart) / 1000000))ms
fi
