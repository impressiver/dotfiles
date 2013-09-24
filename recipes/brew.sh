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

function add_path(){
  local path=$1
  local comment=$2
  local prefix=$3

  local export_line="### !!! Do not modify anything below this line !!! ###"
  local path_line=""

  if $prefix; then
    path_line="PATH=$path:\$PATH"
  else
    path_line="PATH=\$PATH:$path"
  fi

  # Create the path file if it doesn't exist
  if [ ! -f "$HOME/.path" ]; then
    cat > $HOME/.path << EOF
$export_line
PATH=\$(brew --prefix)/bin:\$(brew --prefix)/sbin:\$PATH
export PATH
EOF
  fi

  # Check to see if the path being added is a dupe
  if grep -q -e "$path" $HOME/.path; then
    echo "~/.path already contains '$path'"
    return $FALSE
  else
    # Add comment line
    if [ "$comment" ]; then
    path_line="# $comment\\
$path_line\\
"
    fi

    # Insert new path just above the export line
    sed -i '.backup' "/$export_line/ i \\
$path_line\\
" $HOME/.path
    return $TRUE
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
	add_path '$(brew --prefix coreutils)/libexec/gnubin' 'GNU Coreutils'
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
	# TODO: Need to check for case where nginx installation added '/usr/local/sbin'
	# Should end up as `PATH=$(brew --prefix)/bin:$(brew --prefix)/share/python:$PATH`
	add_path '$(brew --prefix)/share/python' 'Python' true

	# Add OS X default PyObjC libraries to the path
	add_path '/System/Library/Frameworks/Python.framework/Versions/Current/Extras/lib/python/PyObjC' 'OS X built-in PyObjC'
fi

# Install Bash 4
if install 'bash'; then
	if ! grep -q -e "$(brew --prefix)/bin/bash" /etc/shells; then
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