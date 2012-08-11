#!/bin/bash

DEFAULT_SHARED_PREFERENCES_DIR="$HOME/Dropbox/.dotfiles/Library/Application Support"

function doIt() {
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
	cd -
	# IFS=$SAVEIFS
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
	doIt
else
	valid=false
	while ! $valid; do
		read -p "Enter path to shared preferences directory: ('$DEFAULT_SHARED_PREFERENCES_DIR') " SHARED_PREFERENCES_DIR
		sharedprefs=${SHARED_PREFERENCES_DIR:-$DEFAULT_SHARED_PREFERENCES_DIR}

		if [ ! -d "$sharedprefs" ]; then
			echo "The path '$sharedprefs' is not a directory. Please enter the path of the directory where shared preferences are stored."
			valid=false
		else
			valid=true
		fi
	done

	read -p "This may overwrite existing files in '~/Library/Application Support' with files from '$sharedprefs'. Are you sure? (y/n) " -n 1
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		doIt "$sharedprefs"
	fi
fi

unset doIt

echo "Done."