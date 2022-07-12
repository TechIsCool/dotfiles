#!/bin/sh -

link() {
  FROM="$1"
  TO="$2"
  echo "Linking '${FROM}' to '${TO}'"
  if [ -L "${TO}" ]; then
    rm -f "${TO}"
  else
    echo "File: ${TO} is not a symbolic link"
    exit
  fi
  ln -s "${FROM}" "${TO}"
}

export DOTFILE_PATH="${HOME}/src/github/TechIsCool/dotfiles"

# Symlink everything except '.tmpl'
for LOCATION in $(find bash -name '.*' ! -name '.*.tmpl'); do
  FILE="${LOCATION##*/}"
  link "${DOTFILE_PATH}/${LOCATION}" "${HOME}/${FILE}"
done

# Copy '.tmpl' since they are considered secure
for LOCATION in $(find bash -name '*.tmpl'); do
  FILE="${LOCATION##*/}"
  FILE="${FILE/%.tmpl}"
  cp -n "${DOTFILE_PATH}/${LOCATION}" "${HOME}/${FILE}" || true
done

link "${DOTFILE_PATH}/vim/vimfiles" "${HOME}/.vim"
link "${DOTFILE_PATH}/vim/.vimrc" "${HOME}/.vimrc" "${HOME}/.vimrc"


if [[ "$OSTYPE" == "darwin"* ]]; then
  for LOCATION in $(find iterm -name '*.json'); do
    FILE="${LOCATION##*/}"
    link "${DOTFILE_PATH}/${LOCATION}" "${HOME}/Library/Application Support/iTerm2/DynamicProfiles/${FILE}"
  done

  CURRENT_USER=$(ls -l /dev/console | cut -d " " -f4)
  sudo -s -u ${CURRENT_USER} -- <<EOF

    # Finder
      # new window - use src
      defaults write com.apple.finder NewWindowTarget -string "PfLo"
      defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/src"

      # full path in banner
      defaults write com.apple.finder _FXShowPosixPathInTitle -bool true


    # TaskBar
      # Disable siri
      defaults write com.apple.Siri StatusMenuVisible -int 0
      # defaults write com.apple.siri "StatusMenuVisible" -int 0
      # defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" -bool false

      # Enable battery Percent
      defaults write ${HOME}/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

      # Disable Notifications
      defaults write ${HOME}/Library/Preferences/ByHost/com.apple.notificationcenterui dndStart -integer 1
      defaults write ${HOME}/Library/Preferences/ByHost/com.apple.notificationcenterui dndEnd -integer 1439


    # Dock
      # Enable Autohide
      defaults write com.apple.dock autohide -int 1


    # Text
      # Disable smart quotes as they’re annoying when typing code
      defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

      # Disable smart dashes as they’re annoying when typing code
      defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

      # Disable Dictation with fn key pressed twice
      defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0


    # Keyboard
      # When pressing fn/globe by itself, do nothing
      defaults write com.apple.HIToolbox AppleFnUsageType -int 0

      # command:@, control:^, option:~, shift:$
      # Command + L = lock
      defaults write -g NSUserKeyEquivalents '{ \
        "Lock Screen" = "@L"; \
      }'


    # Mouse
      # Disable Natural Scroll Direction
      defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

      # Disable Look up & data detectors: Tap with three fingers
      defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool false

      # Disable Force Click and haptic feedback: Click then press firmly for Quick Look, Look up, and variable speed media controls.
      defaults write NSGlobalDomain com.apple.mouse.forceClick -bool false
      defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false
      defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool true
      defaults write com.apple.preference.trackpad ForceClickSavedState -bool false


    # Bluetooth
      # increase audio bitrate
      defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40


    # iTunes
      # Disable iTunes Music
      defaults write com.apple.iTunes disableAppleMusic -bool true

   # zoom.us
     # Disable Dual Screen
     defaults write /Library/Preferences/us.zoom.config.plist ZDualMonitorOn -bool false

    # Restart UI Elements after Changes
    for APP in \
      "Activity Monitor" \
      "SystemUIServer" \
      "Dock" \
      "NotificationCenter"
    do
	killall "${APP}" &> /dev/null
    done
EOF

  if [[ $(sysctl -in sysctl.proc_translated) = 0 && $(uname -m) != "x86_64" ]]; then
    # Intel CPU
    # Brew
    pushd ${DOTFILE_PATH}/brew
      cat taps.txt | xargs brew tap
      cat packages.txt | xargs -I {} sh -c "brew list {} || brew install"
      cat casks.txt | xargs brew cask install
      cat links.txt | xargs brew link --force
    popd
  else
    # Apple Silicon CPU
    echo 'Skipped Brew due to Applie Silicon'
  fi
fi

# Git Config
link "${DOTFILE_PATH}/git/.gitattributes" "${HOME}/.gitattributes"
link "${DOTFILE_PATH}/git/.gitignore" "${HOME}/.gitignore"
link "${DOTFILE_PATH}/git/.gitconfig" "${HOME}/.gitconfig"
cp -n "${DOTFILE_PATH}/git/.gitcompany.tmpl" "${HOME}/.gitcompany"

mkdir -p ${HOME}/.ssh/
source ${HOME}/.bash_profile

# Install VIM plugins and quit
vim '+PlugInstall' '+qall'
