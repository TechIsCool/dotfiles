#!/bin/sh -

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

for location in $(find bash -name '.*' ! -name '.*.tmpl'); do
  file="${location##*/}"
  link "$HOME/src/dotfiles/$location" "$HOME/$file"
done

link "$HOME/src/dotfiles/vim/vimfiles" "$HOME/.vim"
link "$HOME/src/dotfiles/vim/.vimrc" "$HOME/.vimrc" "$HOME/.vimrc"

source ~/.bash_profile
vim '+PlugInstall' '+qall'
