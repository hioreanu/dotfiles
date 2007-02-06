#!/bin/sh
DOTFILES="$HOME/dotfiles"
SAVE="${DOTFILES}/SAVE"
test -d "${SAVE}" || mkdir "${SAVE}"

linkhome()
{
	src="$1"
	dst="$2"
	test \! -h "${HOME}/${dst}" -a \
			\( -f "${HOME}/${dst}" -o -d "${HOME}/${dst}" \) && \
		mv -f "${HOME}/${dst}" "${SAVE}" && \
		echo "backed up existing ${dst}"
	test -h "${HOME}/${dst}" && \
		echo "ignored existing link ${dst}" && \
		return 0
	ln -s "${DOTFILES}/${src}" "${HOME}/${dst}"
}

linkhome antrc     .antrc
linkhome bashrc    .bashrc
linkhome emacs     .emacs
linkhome emacs.d   .emacs.d
linkhome exrc      .exrc
linkhome muttrc    .muttrc
linkhome screenrc  .screenrc
linkhome vim       .vim
linkhome vimrc     .vimrc
linkhome Xdefaults .Xdefaults
linkhome zshenv    .zshenv
linkhome zshrc     .zshrc
