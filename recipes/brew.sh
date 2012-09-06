#!/bin/bash

INSTALLED_FORMULAE=$(brew list)

# Functions return exit codes; 0 means OK.
TRUE=0
FALSE=1

function install(){
	local formula=$1
	local title=${2:-$formula}
	local args=$3

	if [[ ! "$INSTALLED_FORMULAE" == *$formula* ]]; then
		echo "Installing $title"
		brew install $formula $args

		return $TRUE
	else
		echo "$title already installed"
		return $FALSE
	fi

	return $FALSE
}

# Make sure we’re using the latest Homebrew
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae
echo "Upgrading installed formulae..."
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated)
if install 'coreutils'; then
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
fi

# Install GNU `find`, `locate`, `updatedb`, and `xargs`, g-prefixed
install 'findutils'

# Install wget with IRI support
install 'wget' 'wget' '--enable-iri'

# Install RingoJS and Narwhal
# if [[ ! "$INSTALLED_FORMULAE" == *ringojs* ]]; then
# 	echo "Installing RingoJS and Narwal"
# 	# Note that the order in which these are installed is important; see http://git.io/brew-narwhal-ringo.
# 	brew install ringojs
# 	brew install narwhal
# fi

# Install Python
if install 'python' 'Python'; then
	if [ -f "$HOME/.path" ]; then
		if grep -q -e "$(brew --prefix)/bin:$(brew --prefix)/share/python" $HOME/.path; then
			echo "'~/.path' already contains '$(brew --prefix)/bin:$(brew --prefix)/share/python'"
		else
			sed -i '.backup' "s#^export PATH=\(.*\)\$#export PATH=$(brew --prefix)\/bin:$(brew --prefix)\/share\/python:\1#" $HOME/.path
		fi

		# Add OS X default PyObjC libraries to the path
		if ! grep -q -e "/System/Library/Frameworks/Python.framework/Versions/Current/Extras/lib/python/PyObjC" $HOME/.path; then
			sed -i '.backup' "s#^export PATH=\(.*\)\$#export PATH=\1:/System/Library/Frameworks/Python.framework/Versions/Current/Extras/lib/python/PyObjC#" $HOME/.path
	else
		echo "export PATH=$(brew --prefix)/bin:$(brew --prefix)/share/python:\$PATH" > $HOME/.path
	fi
fi

# Install Bash 4
if install 'bash'; then
	if ! grep -q -e "$(brew --prefix)/bin/bash" $HOME/.path; then
		echo "Need permission to add '$(brew --prefix)/bin/bash' (bash 4) to '/etc/shells'"
		sudo echo $(brew --prefix)/bin/bash >> /etc/shells
		echo "Setting login shell to bash 4"
		chsh -s $(brew --prefix)/bin/bash
	fi
fi

# Install bash-completion
if install 'bash-completion'; then
	# Add homebrew bash-completion
	if grep -q -e "$(brew --prefix)/etc/bash_completion" $HOME/.extra; then
		echo "Homebrew's bash-completion already sourced in '~/.extra'"
	else
###############################################################################
	cat >> $HOME/.extra << EOF

# Homebrew bash-completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
	. $(brew --prefix)/etc/bash_completion
fi
EOF
###############################################################################
	fi
fi

# Install more recent versions of some OS X tools
if [[ ! "$INSTALLED_FORMULAE" == *grep* ]]; then
	echo "Installing updated OS X tools"
	brew tap homebrew/dupes
	brew install homebrew/dupes/grep
	#brew tap josegonzalez/homebrew-php
	#brew install php54

	# These two formulae didn’t work well last time I tried them:
	#brew install homebrew/dupes/vim
	#brew install homebrew/dupes/screen
fi

# Install everything else
install 'ack'
install 'rename'
install 'tree'
#brew install exiv2
install 'git' 'Git'
#brew install imagemagick
install 'lynx' 'Lynx'
install 'node' 'NodeJS'
install 'rhino' 'RhinoJS'
install 'webkit2png'

# Remove outdated versions from the cellar
echo "Cleaning up..."
brew cleanup

# Source $PATH changes
if [ -f "$HOME/.path" ]; then
	source $HOME/.path

	if [ -f "$HOME/.path.backup" ]; then
		rm $HOME/.path.backup
	fi
fi