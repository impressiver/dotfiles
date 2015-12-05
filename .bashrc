echo ".bashrc"

# Interactive-shell
if [ -n "$PS1" ] && [ "$BASH" ]; then
	source ~/.bash_profile
else
	# Non-interactive shell stuff
	for file in ${HOME}/.{path,functions,exports,extra}; do
		[ -r "$file" ] && [ -f "$file" ] && source "$file"
	done
fi
