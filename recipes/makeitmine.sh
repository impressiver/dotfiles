#!/bin/bash

# App Versions
FIREFOX_VERSION='14.0.1'
FLASH_PLAYER_VERSION='11.3.300.268'
SUBLIME_TEXT_2_VERSION='2.0.1'
DROPBOX_VERSION='1.4.12'

cd "$(dirname "$0")"

# Update dotfiles
read -p "Would you like to update your dotfiles before we proceed? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	bash '../bootstrap.sh'
fi

# OS X Defaults
read -p "Would you like to set sensible system defaults? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	bash './osx.sh'
fi

# Homebrew
if [ ! -e /usr/local/bin/brew]; then
	read -p "Would you like to install Homebrew? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		ruby <(curl -fsSk https://raw.github.com/mxcl/homebrew/go)
	fi
fi

# Useful Homebrew formulae
read -p "Would you like to install common Homebrew formulae? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		bash './brew.sh'
	fi
fi

# Useful Homebrew formulae
read -p "Would you like to install common development apps? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		bash './dev.sh'
	fi
fi

# Ask for the administrator password upfront
echo "Please enter administrator password (sudo): "
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get user info up front
echo "When committing to Github, use these details as default:"
read -p "[Github] Full name: " GIT_AUTHOR_NAME
read -p "[Github] Email Address: " GIT_AUTHOR_EMAIL

# Generate a ~/.extra file
if [ -f $HOME/.extra ]
then
	ext = $(date +"%Y%m%d%H%M%s")
	echo "Backing up existing .extra file to '$HOME/.extra.$ext'"
	mv $HOME/.extra $HOME/.extra.$ext
fi

cat > $HOME/.extra << EOF
# PATH additions
export PATH="~/bin:\$PATH"

# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL"

GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"

git config --global user.name "\$GIT_AUTHOR_NAME"
git config --global user.email "\$GIT_AUTHOR_EMAIL"
git config --global credential.helper osxkeychain
EOF

# Software Update (get all available updates)
sudo softwareupdate -i -a

# Google Chrome
if [ ! -d /Applications/Google\ Chrome.app ];
then
	echo "Installing Google Chrome"
	hdiutil attach https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
	cp -R /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
	hdiutil detach /Volumes/Google\ Chrome
else
	echo "[Google Chrome] Chrome is already installed."
fi
echo "[Google Chrome] Don’t forget to install extensions: REST Console, Speed Tracer (https://chrome.google.com/webstore/category/home)"

# Mozilla Firefox
if [ ! -d /Applications/Firefox.app ];
then
	echo "\nInstalling Mozilla Firefox"
	hdiutil attach http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/$FIREFOX_VERSION/mac/en-US/Firefox%20$FIREFOX_VERSION.dmg
	cp -R /Volumes/Firefox/Firefox.app /Applications/
	hdiutil detach /Volumes/Firefox
	cd /tmp/
	curl -LO https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi
	cd -
	/Applications/Firefox.app/Contents/MacOS/firefox -install-global-extension /tmp/addon-1843-latest.xpi
else
	echo "[Mozilla Firefox] Firefox is already installed."
fi
echo "[Mozilla Firefox] Don't forget to enable Firebug extensions: Eventbug, NetExport, and FBTrace (https://getfirebug.com/swarms/Firefox-14.0/)"

# Adobe Flash Player (and browser plugins)
echo "\nInstalling Adobe Flash Player"
hdiutil attach http://fpdownload.macromedia.com/get/flashplayer/pdc/$FLASH_PLAYER_VERSION/install_flash_player_osx.dmg
echo "[Adobe Flash Player] Please follow the prompts. Waiting for Adobe Flash Player installer to quit..."
open -W /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app
hdiutil detach /Volumes/Flash\ Player

if [ ! -d /Applications/Sublime\ Text\ 2.app ];
then
	echo "\nInstalling Sublime Text 2"
	hdiutil attach http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20$SUBLIME_TEXT_2_VERSION.dmg
	cp -R /Volumes/Sublime\ Text\ 2/Sublime\ Text\ 2.app /Applications/
else
	echo "[Sublime Text 2] Sublime Text 2 is already installed"
fi

if [ ! -d /Applications/Dropbox.app ];
then
	echo "\nInstalling Dropbox"
	curl -O http://dl-web.dropbox.com/u/17/b/Dropbox%20$DROPBOX_VERSION.dmg
	hdiutil attach Dropbox%20$DROPBOX_VERSION.dmg
	echo "[Dropbox] Please follow the prompts. Waiting for Dropbox installer to quit..."
	open -W /Volumes/Dropbox\ Installer/Dropbox.app
	hdiutil detach /Volumes/Dropbox\ Installer
else
	echo "[Dropbox] Dropbox is already installed"
fi

