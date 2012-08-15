#!/bin/bash

DEFAULT_SHARED_PREFERENCES_DIR="$HOME/Dropbox/.dotfiles/Library/Application Support"
LOCAL_APP_SUPPORT_DIR="$HOME/Library/Application Support"

cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd -P)"

function usage() {
	echo "prefs.sh [--list] [--add [app]] [--remove [app]] [--force]"
}

function setIt() {
	read -p "Enter path to shared preferences directory: ('$DEFAULT_SHARED_PREFERENCES_DIR') " SHARED_PREFERENCES_DIR
	sharedprefs=${SHARED_PREFERENCES_DIR:-$DEFAULT_SHARED_PREFERENCES_DIR}

	if [ ! -d "$sharedprefs" ]; then
		echo "The path '$sharedprefs' is not a directory. Please enter the path of the directory where shared preferences are stored."
		valid=false
	else
		echo -e "\n# Shared Prefs (dotfiles/recipes/prefs.sh)" >> $HOME/.extra
		echo "export SHARED_PREFERENCES_DIR='$sharedprefs'" >> $HOME/.extra
		valid=true
	fi
}

function listIt() {
	local prefs=$1

	cd "$prefs"
	for app in *; do
		echo "  $app"
	done
	cd $SCRIPT_DIR
}

function addIt() {
	local app=$1

	cp -R "$LOCAL_APP_SUPPORT_DIR/$app" "$sharedprefs/"
}

function removeIt() {
	local app=$1

	echo "Would have removed: $sharedprefs/$app"
}

function syncIt() {
	local prefs=$1

	# SAVEIFS=$IFS
	# IFS=$(echo -en "\n\b")
	cd "$prefs"
	for app in *; do
		echo "Copying preferences for $app"
		# Backup existing prefs
		if [ -d "$HOME/Library/Application\ Support/$app" ]; then
			mv "$HOME/Library/Application\ Support/$app" "$HOME/Library/Application\ Support/$app.backup"
		fi

		cp -R "$prefs/$app" "$HOME/Library/Application Support/"
		# rsync --exclude ".git/" --exclude ".DS_Store" -av "$prefs/$app/" "$HOME/Library/Application\ Support/$app/"
	done
	cd $SCRIPT_DIR
	# IFS=$SAVEIFS
}

sharedprefs=$SHARED_PREFERENCES_DIR

# Make sure the shared prefs path is set
while [ ! -d "$sharedprefs" ]; do
	setIt
done

if [ "$1" == "--list" -o "$1" == "-l" ]; then
	# List prefs currently shared
	echo "Shared prefs:"
	listIt "$sharedprefs"
elif [ "$1" == "--add" -o "$1" == "-a" ]; then
	if [[ -z "$2" || "$2" == .* || ! -d "$LOCAL_APP_SUPPORT_DIR/$2" ]]; then
		# List available prefs on local machine
		echo "Available prefs:"
		listIt "$LOCAL_APP_SUPPORT_DIR"
	else
		# copy prefs from local machine to shared prefs dir
		addIt "$2"
	fi
elif [ "$1" == "--remove" -o "$1" == "-r" ]; then
	if [[ -z "$2" || "$2" == .* || ! -d "$sharedprefs/$2" ]]; then
		# List available prefs in shared dir
		echo "Specify shared prefs to remove:"
		listIt "$sharedprefs"
	else
		# Remove prefs from shared prefs dir
		read -p "This will permanently delete the directory and all files at '$sharedprefs/$app'. Are you sure? (y/n) " -n 1
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			removeIt "$2"
		fi
	fi
elif [ "$1" == "--force" -o "$1" == "-f" ]; then
	# Copy all prefs from shared dir to local machine
	syncIt
elif [ ! -z "$1" ]; then
	usage
else
	# Default is to sync after confirmation
	read -p "This may overwrite existing files in '~/Library/Application Support' with files from '$sharedprefs'. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		syncIt "$sharedprefs"
		echo "Done."
	fi
fi

unset setIt
unset listIt
unset addIt
unset removeIt
unset syncIt
unset usage