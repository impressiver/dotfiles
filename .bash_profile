echo "loading .bash_profile"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH` (generated path additions are also added to this file).
# * ~/.extra can be used for settings you don’t want to commit.
for file in ${HOME}/.{bash_prompt,path,functions,aliases,exports,extra}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file"
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to Bash history file at the end of a session, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
	shopt -s "$option" 2> /dev/null
done
unset option

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

# Add tab completion for `defaults read|write NSGlobalDomain`
# You could just use `-g` instead, but I like being explicit
complete -W "NSGlobalDomain" defaults

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall

# tab complete all the things
[ -f /etc/bash_completion ] && . /etc/bash_completion
[ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion

# Trap and echo non-zero exit codes
EC() {
  echo -e "${GREY}trapped exit code ${?} from pid ${!} ${_}${RESET}"
}
trap EC ERR

# Finally, perform directory check to auto-load project context
#hcd .
