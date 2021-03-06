# Ian's dotfiles (forked from Mathias’s dotfiles)

## Installation

### Using Git and the bootstrap script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with `~/dotfiles` as a symlink.) The bootstrapper script will pull in the latest version and copy the files to your home folder.

```bash
git clone https://github.com/impressiver/dotfiles.git && cd dotfiles && source bootstrap.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
source bootstrap.sh
```

Alternatively, to update while avoiding the confirmation prompt:

```bash
set -- -f; source bootstrap.sh
```

### Git-free install

To install these dotfiles without Git:

```bash
cd; curl -#L https://github.com/impressiver/dotfiles/tarball/master | tar -xzv --strip-components 1 --exclude={README.md,bootstrap.sh,LICENSE-MIT.txt}
```

To update later on, just run that command again.

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files, before any feature testing (such as [detecting which version of `ls` is being used](https://github.com/mathiasbynens/dotfiles/blob/aff769fd75225d8f2e481185a71d5e05b76002dc/.aliases#L21-26)) takes place.

Here’s an example `~/.path` file that adds `~/bin` to the `$PATH`:

```bash
export PATH="$HOME/bin:$PATH"
```

### Add custom commands without creating a new fork

If `~/.extra` exists, it will be sourced along with the other files. You can use this to add a few custom commands without the need to fork this entire repository, or to add commands you don’t want to commit to a public repository.

My `~/.extra` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="<Your Name>"
GIT_AUTHOR_EMAIL="<Your Email Address>"

GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
```

You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/impressiver/dotfiles/fork_select) instead, though.

### Get comfortable in a hurry

Run this script on a shiny new Mac (new machine, or a clean install of OS X) to get your environment set up the way you like it. This is the kitchen-sink script, it runs all the other scripts after updating your dotfiles:

```bash
./recipes/makeitmine.sh
```

### Install Development Apps

Run this to install a bunch of common apps (both CLI and Desktop), tailored toward web development:

```bash
./recipes/dev.sh
```

### Install Homebrew formulae

<<<<<<< HEAD
You may also want to install some common [Homebrew](http://brew.sh/) formulae (after installing Homebrew, of course):

```bash
./recipes/brew.sh
```

### Sensible OS X defaults

You might want to tweak the default settings from time to time, it's OK to run this more than once:

```bash
./recipes/osx.sh
```

### Shared Preferences

If you use Dropbox, or any other cloud sync service, you can share preferences across machines using this recipe. It will individually copy app prefs in `$HOME/Dropbox/.dotfiles/Library/Application Support` to `$HOME/Library/Application Support` (after making a backup, just in case):

```bash
./recipes/prefs.sh
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/impressiver/dotfiles/issues)!

## Thanks to…

* [Mathias Bynens](http://mathiasbynens.be/) for building an awesome [dotfiles project](https://github.com/mathiasbynens/dotfiles).
