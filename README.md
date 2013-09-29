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

<<<<<<< HEAD
You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/impressiver/dotfiles/fork_select) instead, though.
=======
You could also use `~/.extra` to override settings, functions and aliases from my dotfiles repository. It’s probably better to [fork this repository](https://github.com/mathiasbynens/dotfiles/fork) instead, though.
>>>>>>> 6c98b40f4d9b692863e4e58cfcb355058d5b8544

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
You may also want to install some common Homebrew formulae (after installing Homebrew, of course):

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
=======
When setting up a new Mac, you may want to install some common [Homebrew](http://brew.sh/) formulae (after installing Homebrew, of course):
>>>>>>> 6c98b40f4d9b692863e4e58cfcb355058d5b8544

```bash
./recipes/prefs.sh
```

## Feedback

Suggestions/improvements
[welcome](https://github.com/impressiver/dotfiles/issues)!

## Author

| [![twitter/mathias](http://gravatar.com/avatar/24e08a9ea84deb17ae121074d0f17125?s=70)](http://twitter.com/mathias "Follow @mathias on Twitter") |
|---|
| [Mathias Bynens](http://mathiasbynens.be/) |

## Thanks to…

<<<<<<< HEAD
* [Mathias Bynens](http://mathiasbynens.be/) for building an awesome [dotfiles project](https://github.com/mathiasbynens/dotfiles).
=======
* @ptb and [his _OS X Lion Setup_ repository](https://github.com/ptb/Mac-OS-X-Lion-Setup)
* [Ben Alman](http://benalman.com/) and his [dotfiles repository](https://github.com/cowboy/dotfiles)
* [Chris Gerke](http://www.randomsquared.com/) and his [tutorial on creating an OS X SOE master image](http://chris-gerke.blogspot.com/2012/04/mac-osx-soe-master-image-day-7.html) + [_Insta_ repository](https://github.com/cgerke/Insta)
* [Cãtãlin Mariş](https://github.com/alrra) and his [dotfiles repository](https://github.com/alrra/dotfiles)
* [Gianni Chiappetta](http://gf3.ca/) for sharing his [amazing collection of dotfiles](https://github.com/gf3/dotfiles)
* [Jan Moesen](http://jan.moesen.nu/) and his [ancient `.bash_profile`](https://gist.github.com/1156154) + [shiny _tilde_ repository](https://github.com/janmoesen/tilde)
* [Lauri ‘Lri’ Ranta](http://lri.me/) for sharing [loads of hidden preferences](http://lri.me/osx.html#hidden-preferences)
* [Matijs Brinkhuis](http://hotfusion.nl/) and his [dotfiles repository](https://github.com/matijs/dotfiles)
* [Nicolas Gallagher](http://nicolasgallagher.com/) and his [dotfiles repository](https://github.com/necolas/dotfiles)
* [Sindre Sorhus](http://sindresorhus.com/)
* [Tom Ryder](http://blog.sanctum.geek.nz/) and his [dotfiles repository](https://github.com/tejr/dotfiles)

* anyone who [contributed a patch](https://github.com/mathiasbynens/dotfiles/contributors) or [made a helpful suggestion](https://github.com/mathiasbynens/dotfiles/issues)
>>>>>>> 6c98b40f4d9b692863e4e58cfcb355058d5b8544
