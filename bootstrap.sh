#!/bin/sh -

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

export DOTFILE_PATH="$HOME/src/github/TechIsCool/dotfiles"

# Symlink everything except '.tmpl'
for location in $(find bash -name '.*' ! -name '.*.tmpl'); do
  file="${location##*/}"
  link "${DOTFILE_PATH}/$location" "$HOME/$file"
done

# Copy '.tmpl' sincethey are considered secure
for location in $(find bash -name '*.tmpl'); do
  file="${location##*/}"
  file="${file/%.tmpl}"
  cp -n "${DOTFILE_PATH}/$location" "$HOME/$file" || true
done

link "${DOTFILE_PATH}/vim/vimfiles" "$HOME/.vim"
link "${DOTFILE_PATH}/vim/.vimrc" "$HOME/.vimrc" "$HOME/.vimrc"

if [[ "$OSTYPE" == "darwin"* ]]; then
  for location in $(find iterm -name '*.json'); do
    file="${location##*/}"
    link "${DOTFILE_PATH}/$location" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/$file"
  done

  currentUser=$(ls -l /dev/console | cut -d " " -f4)
  sudo -s -u $currentUser -- <<EOF
    # command:@, control:^, option:~, shift:$
    # Command + L = lock
    defaults write -g NSUserKeyEquivalents '{ \
      "Lock Screen" = "@L"; \
    }'

    # Disable smart quotes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

    # Disable smart dashes as they’re annoying when typing code
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

    # Enable battery Percent
    defaults write com.apple.menuextra.battery ShowPercent YES

    # Disable Dictation with fn key pressed twice
    defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0

    # Disable Natural Scroll Direction
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # Enable Dock Autohide
    defaults write com.apple.dock autohide -int 1

    # Disable Notifications
    defaults write ~/Library/Preferences/ByHost/com.apple.notificationcenterui dndStart -integer 1
    defaults write ~/Library/Preferences/ByHost/com.apple.notificationcenterui dndEnd -integer 1439

    # Disable iTunes Music
    defaults write com.apple.iTunes disableAppleMusic -bool true

    # Restart UI Elements after Changes
    # Taskbar
    killall SystemUIServer
    # Dock
    killall Dock
    # Notification Center
    killall NotificationCenter
EOF

  pushd ${DOTFILE_PATH}/brew
    cat taps.txt | xargs brew tap
    cat packages.txt | xargs brew install
    cat casks.txt | xargs brew cask install
    cat links.txt | xargs brew link --force
  popd
fi

mkdir $HOME/.ssh/ || true
source $HOME/.bash_profile

vim '+PlugInstall' '+qall'
