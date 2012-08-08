#!/bin/bash

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
brew install coreutils
#if [[ $PATH == *$(brew --prefix coreutils)/libexec/gnubin* ]]; then
if [ -f "$HOME/.path" ]; then
	if grep -q -e "$(brew --prefix coreutils)/libexec/gnubin" $HOME/.path; then
		echo "'~/.path' already contains '$(brew --prefix coreutils)/libexec/gnubin'"
	else
		sed -i '.backup' "s#^export PATH=\(.*\)\$#export PATH=\1:$(brew --prefix coreutils)\/libexec\/gnubin#" $HOME/.path
	fi
else
	echo "export PATH=\$PATH:$(brew --prefix coreutils)/libexec/gnubin" > $HOME/.path
fi

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
brew install findutils

# Install wget with IRI support
brew install wget --enable-iri

# Install RingoJS and Narwhal
# Note that the order in which these are installed is important; see http://git.io/brew-narwhal-ringo.
#brew install ringojs
#brew install narwhal

# Install Python
brew install python
#if [[ $PATH == *$(brew --prefix coreutils)/libexec/gnubin* ]]; then
if [ -f "$HOME/.path" ]; then
	if grep -q -e "$(brew --prefix)/bin:$(brew --prefix)/share/python" $HOME/.path; then
		echo "'~/.path' already contains '$(brew --prefix)/bin:$(brew --prefix)/share/python'"
	else
		sed -i '.backup' "s#^export PATH=\(.*\)\$#export PATH=$(brew --prefix)\/bin:$(brew --prefix)\/share\/python:\1#" $HOME/.path
	fi
else
	echo "export PATH=$(brew --prefix)/bin:$(brew --prefix)/share/python:\$PATH" > $HOME/.path
fi

# Install more recent versions of some OS X tools
brew tap homebrew/dupes
brew install homebrew/dupes/grep
#brew tap josegonzalez/homebrew-php
#brew install php54

# These two formulae didn’t work well last time I tried them:
#brew install homebrew/dupes/vim
#brew install homebrew/dupes/screen

# Install everything else
brew install ack
#brew install exiv2
brew install git
#brew install imagemagick
brew install lynx
brew install node
brew install rename
brew install rhino
brew install tree
brew install webkit2png

# Remove outdated versions from the cellar
brew cleanup

# Source $PATH changes
if [ -f "$HOME/.path" ]; then
	source $HOME/.path
	rm $HOME/.path.backup
fi