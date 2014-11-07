# .bashrc                           updated:  Sun Apr  8 03:13:05 2001
# $Id$
# NOTE: I use zsh, not bash.  This is obsolete and unused.

# xdm sources this in posix mode, breaks things later on:
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
alias j="builtin jobs -l"
alias p=pwd
alias wpd=pwd
alias st=sound-toggle
alias kilmoz='killall -9 netscape'
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
