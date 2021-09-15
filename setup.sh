#!/bin/sh

# OSX install script a lot has been bored from https://github.com/nnja/new-computer and https://github.com/ruyadorno/installme-osx

# Set the colours you can use
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

echo ""
cecho "Install script for newly installed 🍎 computer" $green
cecho "Some choices are highly personal !" $green
echo ""


# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


echo ""
cecho "Installing brew... 🍺" $blue

if test ! $(which brew)
then
	## Don't prompt for confirmation when installing homebrew
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
fi

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$USER/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"remi

# Latest brew, install brew cask
brew upgrade
brew update
brew tap homebrew/cask


cecho "Generating ssh keys, adding 🔑" $green
read -p 'Input email for ssh key: ' useremail


cecho "generate ed25519 key  " $blue
# no passphrase
ssh-keygen -t ed25519 -C "$usermail" -q -N ""


cecho "generate rsa key for old server that does not support ed25519 " $blue
# no passphrase
ssh-keygen -t rsa -b 8192 -C "$useremail" -q -N ""

#############################################
### Add ssh-key to GitHub via api
#############################################

cecho "Adding ssh-key to GitHub (via api)... 🔑" $green
cecho "Important! For this step, use a github personal token with the admin:public_key permission." $yellow
cecho "If you don't have one, create it here: https://github.com/settings/tokens/new" $yellow

retries=3
SSH_KEY=`cat ~/.ssh/id_ed25519.pub`

for ((i=0; i<retries; i++)); do
      read -p 'GitHub username: ' ghusername
      read -p 'Machine name: ' ghtitle
      read -sp 'GitHub personal token: ' ghtoken

      gh_status_code=$(curl -o /dev/null -s -w "%{http_code}\n" -u "$ghusername:$ghtoken" -d '{"title":"'$ghtitle'","key":"'"$SSH_KEY"'"}' 'https://api.github.com/user/keys')

      if (( $gh_status_code -eq == 201))
      then
          echo "GitHub ssh key added successfully!"
          break
      else
			echo "Something went wrong. Enter your credentials and try again..."
     		echo -n "Status code returned: "
     		echo $gh_status_code
      fi
done


[[ $retries -eq i ]] && cecho "Adding ssh-key to GitHub failed! Try again later." $red

cecho "Starting brew app install... 👨‍💻" $green

brew install --cask spectacle

### Developer Tools
brew install --cask iterm2
curl -L -o solarized https://ethanschoonover.com/solarized/files/solarized.zip
cecho "Solaried ☀ theme download in home dir. You have to install it yourself ☹️" $red
brew install ispell
brew install vim --with-python --with-ruby --with-perl
brew install macvim --env-std --override-system-vim

brew install git  # upgrade to latest
brew install git-lfs # track large files in git https://github.com/git-lfs/git-lfs
read -p 'Input email for git setup: ' gitemail
git config --global user.email "$gitemail"
read -p 'Input name for git setup: ' gitname
git config --global user.name "$gitname"


brew install wget htop
brew install zsh zsh-completions
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
sed -i -e 's/ZSH_THEME=\".*\"/ZSH_THEME=\"agnoster\"/g' $HOME/.zshrc
brew install tree
brew link curl --force
brew install grep --with-default-names
brew install less
brew install bat
brew install gpg
brew install fzf
# To install useful key bindings and fuzzy completion:
$(brew --prefix)/opt/fzf/install
brew install bitwarden-cli
brew install --cask bitwarden



### Python
brew install python
brew install pyenv
brew install ipython
pip3 install --upgrade pip

### browser
brew install --cask opera 
brew install --cask firefox

brew install --cask visual-studio-code
brew install --cask flux

brew install --cask docker
brew install docker-compose
brew install docker-machine
brew install kotlin
brew install elixir
brew install --cask pgadmin4

### Quicklook plugins https://github.com/sindresorhus/quick-look-plugins
brew install --cask qlcolorcode # syntax highlighting in preview
brew install --cask qlstephen  # preview plaintext files without extension
brew install --cask qlmarkdown  # preview markdown files
brew install --cask quicklook-json  # preview json files
brew install --cask epubquicklook  # preview epubs, make nice icons
brew install --cask quicklook-csv  # preview csvs

brew install --cask slack

brew install --cask adoptopenjdk

brew install --cask vlc
brew install --cask spotify


#brew tap caskroom/fonts

#cd ~/Library/Fonts && { curl -O 'https://github.com/Falkor/dotfiles/blob/master/fonts/SourceCodePro+Powerline+Awesome+Regular.ttf?raw=true' ; cd -; }


cecho "Installing apps from the App Store... 🏬" $green

### find app ids with: mas search "app name"
brew install mas

cecho "Need to log in to App Store manually to install apps with mas...." $red
echo "Opening App Store. Please login."
open "/Applications/App Store.app"
echo "Is app store login complete.(y/n)? "
read response
if [ "$response" != "${response#[Yy]}" ]
then
	mas install 494803304  # wifi explorer.
else
	cecho "App Store login not complete. Skipping installing App Store Apps" $red
fi



cecho "cleanup brew" $green
brew cleanup


##################
### Finder, Dock, & Menu Items
##################

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Only Show Open Applications In The Dock  
defaults write com.apple.dock static-only -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable the “Are you sure you want to open this application?” dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Disable smart quotes and smart dashes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

defaults write com.apple.dock mru-spaces -bool false

# Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Menu bar: hide the Time Machine, Volume, and User icons
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
   defaults write "${domain}" dontAutoLoad -array \
      "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu"
done
defaults write com.apple.systemuiserver menuExtras -array \
   "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
   "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
   "/System/Library/CoreServices/Menu Extras/Battery.menu" \
   "/System/Library/CoreServices/Menu Extras/Clock.menu"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

###############################################################################
# Spotlight                                                                   #
###############################################################################

# Hide Spotlight tray-icon (and subsequent helper)
#sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search
# Disable Spotlight indexing for any volume that gets mounted and has not yet
# been indexed before.
# Use `sudo mdutil -i off "/Volumes/foo"` to stop indexing any volume.
sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
# Load new settings before rebuilding the index
killall mds



###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Disable “natural” (Lion-style) scrolling
# Uncomment if you don't use scroll reverser
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

#"Disable smart quotes and smart dashes as they are annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###
# SSD
###
# Disable hibernation (speeds up entering sleep mode)
sudo pmset -a hibernatemode 0

#"Disabling system-wide resume"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false



# Remove the sleep image file to save disk space
sudo rm /private/var/vm/sleepimage
# Create a zero-byte file instead…
sudo touch /private/var/vm/sleepimage
# …and make sure it can’t be rewritten
sudo chflags uchg /private/var/vm/sleepimage

# Disable the sudden motion sensor as it’s not useful for SSDs
sudo pmset -a sms 0


# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

# Bottom left screen corner → Mission Control
#defaults write com.apple.dock wvous-bl-corner -int 2
#defaults write com.apple.dock wvous-bl-modifier -int 0


# Bottom right screen corner → Start screen saver
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0

# this works on elcap. Need to download on > 10.11 😥.
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Library/Desktop Pictures/Shapes.jpg"'



echo ""
cecho "Done!" $cyan
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
echo ""
echo ""
echo -n "Check for and install available OSX updates, install, and automatically restart? (y/n)? "
read response
if [ "$response" != "${response#[Yy]}" ] ;then
    softwareupdate -i -a --restart
fi
