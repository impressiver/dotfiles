#!/bin/bash

cd "$(dirname "$0")"

# Ask for the administrator password upfront
echo "Please enter administrator password (sudo): "
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Get user info up front
echo "When committing to Github, use these details as default:"
read -p "[Github] Full name: " GIT_AUTHOR_NAME
read -p "[Github] Email Address: " GIT_AUTHOR_EMAIL

# Generate new ~/.extra file
extra_path='~/bin:$PATH'

if [ -f $HOME/.extra ]
then
	#ext=$(date +"%Y-%m-%d.%H%M%s")
	ext='backup'
	echo "Backing up existing .extra file to '$HOME/.extra.$ext'"
	mv $HOME/.extra $HOME/.extra.$ext
fi

cat > $HOME/.extra << EOF
# PATH additions
export PATH=$extra_path

# Git credentials
GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL"

GIT_COMMITTER_NAME="\$GIT_AUTHOR_NAME"
GIT_COMMITTER_EMAIL="\$GIT_AUTHOR_EMAIL"

git config --global user.name "\$GIT_AUTHOR_NAME"
git config --global user.email "\$GIT_AUTHOR_EMAIL"
git config --global credential.helper osxkeychain
EOF
source $HOME/.extra

# OS X Software Update (get all available updates)
sudo softwareupdate -i -a

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
if [ ! -e /usr/local/bin/brew ]; then
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

# Useful dev apps
read -p "Would you like to install common development apps? (y/n) " -n 1
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	bash './dev.sh'
fi

