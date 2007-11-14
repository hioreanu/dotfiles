# .bashrc                           updated:  Sun Apr  8 03:13:05 2001
# $Id$

# xdm sources this in posix mode, fucks up some things later on:
set +o posix
set -ab
set +u

if [ -z "$PATH" ] ; then
	PATH="/bin:/usr/bin"
fi
EDITOR=vi
VISUAL=$EDITOR
LESS="-f -M -e -g -i -X"
PAGER=less
IGNOREEOF=0
INFOPATH=/usr/local/info:/usr/info:/usr/share/texmf/teTeX/info
KDEDIR=/usr/local/kde
QTDIR=/usr/local/qt
INFODIR=$INFOPATH
HOSTESS="`hostname | sed 's/\..*$//g' | tr '[a-z]' '[A-Z]'`"
PS1="${HOSTESS}\\$ "
LS_OPTIONS="-N -B --color=tty -T 0"
LS_COLORS="di=0;34:ln=0;36:pi=1;33:so=1;35:bd=1;34:cd=1;32:ex=0;35:or=0;31:"
MAILHOST=nsit-popmail.uchicago.edu
NNTPSERVER=uchinews
CVS_RSH=ssh
CVSEDITOR=vi
CVSROOT=~/CVSROOT
unset MAILCHECK

if [ -z $MANPATH ] ; then
	MANPATH=/opt/man:/usr/man:/usr/local/man:/usr/X11R6/man:
	MANPATH=$MANPATH:/usr/openwin/man:/usr/share/man:/opt/SUNWspro/man
fi
MANPATH=$MANPATH:/usr/lib/perl5/man

pathdel() {
	PATH=`echo $PATH | sed -e "s/\(.*\)\(\:\)$1\(\:\)\(.*\)/\1:\4/g" \
	                       -e "s/^$1://" -e "s/:$1\$//"`
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
if [ "$UID" == "0" ] ; then
	pathadd /sbin "append"
	pathadd /usr/sbin "append"
	pathadd /usr/local/sbin "append"
	for i in /usr/local/*/sbin ; do pathadd $i "append" ; done
	for i in /opt/*/sbin ; do pathadd $i "append" ; done
fi
pathadd /opt/bin "append"
for i in /opt/*/bin ; do pathadd $i "append" ; done
for i in /usr/local/*/bin ; do pathadd $i "prepend" ; done
pathadd /usr/local/bin "prepend"
pathadd /usr/ucb "append"
pathadd /usr/ccs/bin "append"
pathadd /usr/xpg4/bin "append"
pathadd ~/bin "prepend"

if [ -e /ntldr ] ; then
    NT="YES"
    W32="YES"
    alias emacs="/emacs/bin/emacs.bat -bg black"
elif [ -d /WINDOWS ] ; then
	WINDOWS="YES"
    W32="YES"
    alias emacs="HOME=N: /emacs/bin/runemacs -bg black"
else
    W32="NO"
fi

unalias -a
alias playnes='ines -sound 46137344 -sync 20 -scale 2'
alias ciao="logout 2> /dev/null; exit" # FIXME: map C-d to this
alias j="builtin jobs -l"
alias p=pwd
alias wpd=pwd
alias st=sound-toggle
alias kilmoz='killall -9 netscape'
alias websuck='wget -r --no-parent'
alias gdb='gdb -q'
alias bc='bc -q'
alias standby='xset dpms force standby'
alias nchars='awk "{print length()}"'
alias ls-l='ls -l'
alias gv='gv -antialias -noresize'
if ls --version > /dev/null 2>&1 ; then
    alias ls='ls $LS_OPTIONS'
fi

beep() {
    echo -e '\007'
    xrefresh -solid white 2> /dev/null
    xkbbell 2> /dev/null
}
sos() {
    go() {
        xkbbell 2> /dev/null
        xrefresh -solid black 2> /dev/null
        xrefresh -solid white 2> /dev/null
        echo -ne '\007'
        usleep 200000
    }

    xset b 100 1500 100
    go ; go ; go
    xset b 100 1500 200
    go ; go ; go
    xset b 100 1500 100
    go ; go ; go

    unset go
    xset b
}
fileprogress() {
    tput clear
    if [ $# -gt 1 ] ; then
        TOTAL=$2
        FMT='"\r%.2fM (%.2f%%)"'
    else
        TOTAL=1
        FMT='"\r%.2fM"'
    fi
    while true ; do
        ls -l $1 | awk "{printf($FMT, \$5/(1024*1024), (\$5 / $TOTAL)*100)}"
        sleep 1
    done
}
checkmail() {
	LOGSIZE=`ls -l ~/.procmail.log | awk '{print $5}'`
    klist -s \
      && test `klist | awk -F'  ' 'NR==5 {print $2}' \
      | date -f - +"%s"` -ge `date +"%s"`
    if [ $? -eq 0 ]; then
        if fetchmail -s ; then
			 NEWLOGSIZE=`ls -l ~/.procmail.log | awk '{print $5}'`
			 DIFF=$(( $NEWLOGSIZE - $LOGSIZE ))
			 tail -c $DIFF ~/.procmail.log
             return 0
        else
            echo "No mail...loser...." # also, something may have gone wrong
            return 1
        fi
    else
        kinit ahiorean
        checkmail
    fi
}
playm3u() {
	while read i ; do mpg123 "$i" ; done < $1
}
megs() {
    ls -la $@ | awk '{x += $5} END { printf("%.2f\n", (x / 1048576)) }'
}
dirs() { 
    # /^d/ { print $9 } won't work with dir names w/ spaces in them
    # and {print(substr($0,index($0,$9)))} won't work /w 1, 2, etc. as dirnames
    ls -lA $@ | awk '/^d/ { print(substr($0, index($0, $9))); }'
}
recurse() { # DFS
    for DIR in `dirs` ; do
        $@
        cd $DIR
        recurse $@
        cd ..
    done
}
rename() {
# snarfed from Larry Wall
	perl -e '
		$op = shift;
        for (@ARGV) {
            $was = $_;
            eval $op;
            die $@ if $@;
            rename($was,$_)
			unless $was eq $_;
        }' $@
}
# in case someone walks up, switches to vt2 and hits C-c
x() {
    if xdpyinfo >/dev/null 2>&1; then 
        echo IDIOT!
    else
        cd
        startx &
        logout
    fi
}
getgreen() {
    echo -e "\033[0;32m"
    export LS_OPTIONS='-G -N -T 0'
}
l() {
    ls --color -C $@ | less -r -E
}
empty() {
    ls -lag $@ | awk '$5 == 0 {print $9}'
}
where() {
    builtin type -a "$@"
}
dirsizes() {
    du -s `dirs` \
    | sort -nr \
    | awk '{print $2}' \
    | xargs du -sh
}
timecommand() {
    clear 
    while true 
    do 
        printf "\r%s" "`date +"%T"`"
        sleep 1
    done
}
biggestdir() {
    dirsizes 2> /dev/null | head -1
}
makepasswd() {
    dd if=/dev/random bs=6 count=1 2>/dev/null \
    | uuencode -m - \
    | head -2 \
    | tail -1 \
    | tr -d 3 
}
texwc() {
    perl -e 'while(<>) { 
        if (/%/) {
            /^(.*)%/; 
            $j=$1;
        } else {$j=$_;} 
        foreach $i (split(/\s/, $j)) {
            print $i . "\n" if not $i =~ /^\\/;
        }
    }' | wc -w
}
randsort() {
    perl -e 'srand(time() ^ ($$ + ($$ << 15)));
             print sort {rand 10 <=> rand 10} <STDIN>;'
}
endian() {
    if echo "ab" | od -x | grep "6261" >/dev/null; then
        echo "little"
    else
        echo "big"
    fi
}
xtitle() {
	echo -e "\033]2;$*\007" | tr -d '\012'
}
#if [ ! -z $DISPLAY ] ; then
#    cd() {
#        builtin cd "$@" && xtitle "$HOSTESS: $PWD"
#    }
#fi
if [ -d ~/nsmail ] ; then
    rm -rf ~/nsmail;
fi

shopt -s cmdhist
shopt -s interactive_comments
set -u
if [ "$UID" == "0" ] ; then
	umask 022
else
	umask 077
fi
if [ $W32 == "YES" ] ; then
	shopt -s nocaseglob
	if [ $NT == "YES" ] ; then
		PS1="NT\$ "
	else
		PS1="W9X\$ "
	fi
	cd
else
    shopt -s cdspell
    ulimit -c unlimited
fi

if [ -e ~/.bash-local ] ; then
	. ~/.bash-local
fi

################################################################################

alias gotoyx='tput cup'
printled() {
    declare -a led
    case $2 in
#                0   1   2   3   4   5   6   7   8
        0) led=(' ' '_' ' ' '|' ' ' '|' '|' '_' '|') ;;
        1) led=(' ' ' ' ' ' ' ' ' ' '|' ' ' ' ' '|') ;;
        2) led=(' ' '_' ' ' ' ' '_' '|' '|' '_' ' ') ;;
        3) led=(' ' '_' ' ' ' ' '_' '|' ' ' '_' '|') ;;
        4) led=(' ' ' ' ' ' '|' '_' '|' ' ' ' ' '|') ;;
        5) led=(' ' '_' ' ' '|' '_' ' ' ' ' '_' '|') ;;
        6) led=(' ' '_' ' ' '|' '_' ' ' '|' '_' '|') ;;
        7) led=(' ' '_' ' ' ' ' ' ' '|' ' ' ' ' '|') ;;
        8) led=(' ' '_' ' ' '|' '_' '|' '|' '_' '|') ;;
        9) led=(' ' '_' ' ' '|' '_' '|' ' ' ' ' '|') ;;
        .) led=(' ' ' ' ' ' ' ' ' ' ' ' ' ' '.' ' ') ;;
        :) led=(' ' ' ' ' ' ' ' '.' ' ' ' ' '.' ' ') ;;
        %) led=(' ' ' ' ' ' ' ' 'o' '/' ' ' '/' 'o') ;;
        *) led=(' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ') ;;
    esac
    for i in 0 3 6; do
        gotoyx `expr $i / 3` $1
        for j in 0 1 2; do
            echo -n "${led[`expr $i + $j`]}"
        done
    done
}
printinled () {
    trap 'tput reset; tput cnorm; gotoyx 0 0' 2
#    echo -e $BG_BLACK $FG_GREEN
    tput civis
    current_column=0
    while [ $# -ne 0 ]; do
        for char in `echo $1 | sed 's/\(.\)/& /g'` ; do
            printled $current_column $char
            current_column=`expr $current_column + 3`
        done
        shift
    done
    unset current_column char
}
alias grdc='tput clear; while true ; do printinled `date +"%k:%M:%S"`; done'
#clear;while true;do (sleep 1;printinled `ls -l /mnt/1/burn/ydl-cs1.1-install.img | awk '{printf("%.2f%%", $5/(1024*1024*6.5))}'`);done

#  export inversescreen=`tput smso`
#  export uninversescreen=`tput rmso`
#  export FG_BLACK=`tput setaf 0`
#  export BG_BLACK=`tput setab 0`
#  export FG_RED=`tput setaf 1`
#  export BG_RED=`tput setab 1`
#  export FG_GREEN=`tput setaf 2`
#  export BG_GREEN=`tput setab 2`
#  export FG_YELLOW=`tput setaf 3`
#  export BG_YELLOW=`tput setab 3`
#  export FG_BLUE=`tput setaf 4`
#  export BG_BLUE=`tput setab 4`
#  export FG_MAGENTA=`tput setaf 5`
#  export BG_MAGENTA=`tput setab 5`
#  export FG_CYAN=`tput setaf 6`
#  export BG_CYAN=`tput setab 6`
#  export FG_WHITE=`tput setaf 7`
#  export BG_WHITE=`tput setab 7`

#export PS1="\[\033[$(($COLUMNS - 5))G\]\[\033[0;34m\]\$(date +%H:%M)\[\033[0G\]\[\033[0;32m\]\u@\w> "
#export PS1="\[\033[$(($COLUMNS - 3))G\]\[\033[0;34m\]\$(date +%H%M)\[\033[0G\]\[\033[m\]\u@\w> "

#"\[\033[COLORm\]" #turns on the specified COLOR
#    Black       0;30     Dark Gray     1;30
#    Blue        0;34     Light Blue    1;34
#    Green       0;32     Light Green   1;32
#    Cyan        0;36     Light Cyan    1;36
#    Red         0;31     Light Red     1;31
#    Purple      0;35     Light Purple  1;35
#    Brown       0;33     Yellow        1;33
#    Light Gray  0;37     White         1;37
#"\[\033[NUMBERG\]" #goto this column NUMBER (remember the 'G')
