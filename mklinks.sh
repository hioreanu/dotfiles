#!/bin/sh
DOTFILES="$HOME/dotfiles"
set -x
ln -s "$DOTFILES/antrc"     "$HOME/.antrc"
ln -s "$DOTFILES/bashrc"    "$HOME/.bashrc"
ln -s "$DOTFILES/emacs"     "$HOME/.emacs"
ln -s "$DOTFILES/emacs.d"   "$HOME/.emacs.d"
ln -s "$DOTFILES/exrc"      "$HOME/.exrc"
ln -s "$DOTFILES/muttrc"    "$HOME/.muttrc"
ln -s "$DOTFILES/vim"       "$HOME/.vim"
ln -s "$DOTFILES/vimrc"     "$HOME/.vimrc"
ln -s "$DOTFILES/Xdefaults" "$HOME/.Xdefaults"
ln -s "$DOTFILES/zshenv"    "$HOME/.zshenv"
ln -s "$DOTFILES/zshrc"     "$HOME/.zshrc"
