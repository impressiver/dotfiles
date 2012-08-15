# App Versions
SEQUELPRO_VERSION='0.9.9.1'
FIREFOX_VERSION='14.0.1'
FLASH_PLAYER_VERSION='11.3.300.268'
SUBLIME_TEXT_2_VERSION='2.0.1'
TEXTMATE_VERSION='1.5.11_r1635'
DROPBOX_VERSION='1.4.12'
ONEPASSWORD_VERSION='3.8.20'
ADIUM_VERSION='1.5.2'

INSTALLED_FORMULAE=$(brew list)
# Functions return exit codes; 0 means OK.
TRUE=0
FALSE=1

# Homebrew formula install helper
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

### CLI Apps ###

# We're going to need this later
mkdir -p $HOME/Library/LaunchAgents

# "Hub" for Github (http://defunkt.io/hub/)
install 'hub' 'Hub'

# Python: Install pip, virtualenv, and virtualenvwrapper
if [ ! -e /usr/local/bin/python ]; then
	echo "Skipping virtualenv setup. Python was not installed by Homebrew."
else
	if [ ! -e /usr/local/share/python/pip ]; then
		echo "Installing pip"
		easy_install pip
	fi

	installed_packages=$(pip freeze)

	if [[ ! "$installed_packages" == *virtualenv* ]]; then
		echo "Installing virtualenv"
		pip install virtualenv
	fi

	if [[ ! "$installed_packages" == *virtualenvwrapper* ]]; then
		echo "Installing virtualenvwrapper"
		pip install virtualenvwrapper
	fi

	if grep -q -e "^WORKON_HOME=" $HOME/.extra; then
		echo "\$WORKON_HOME already set in '~/.extra'"
		echo "The following values are suggested:"
		echo "  export WORKON_HOME=~/.virtualenvs"
		echo "  export PROJECT_HOME=~/Projects"
		echo "  source virtualenvwrapper_lazy.sh"
	else
		echo -e "\n# virtualenvwrapper" >> $HOME/.extra
		echo "export WORKON_HOME=~/.virtualenvs" >> $HOME/.extra
		echo "export PROJECT_HOME=~/Projects" >> $HOME/.extra
		echo "source virtualenvwrapper_lazy.sh" >> $HOME/.extra
	fi

	mkdir -p $HOME/.virtualenvs
	source $HOME/.extra
	source virtualenvwrapper.sh
fi

# Install MySQL and set to launch at startup
if install 'mysql'; then
	unset TMPDIR
	mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
	cp /usr/local/Cellar/mysql/5.5.25a/homebrew.mxcl.mysql.plist $HOME/Library/LaunchAgents/
	launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.mysql.plist

	echo
	read -p "[MySQL] Please enter a password for root (default is blank): "
	echo
	if $REPLY; then
		/usr/local/Cellar/mysql/5.5.25a/bin/mysqladmin -u root password "$REPLY"
		/usr/local/Cellar/mysql/5.5.25a/bin/mysqladmin -u root -h $(hostname) password "$REPLY"
	fi
fi

# Install Memcached and set to launch at startup
if install 'memcached'; then
	cp /usr/local/Cellar/memcached/1.4.14/homebrew.mxcl.memcached.plist $HOME/Library/LaunchAgents/
	launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.memcached.plist
fi

# Redis
# if install 'redis'; then
# 	cp /usr/local/Cellar/redis/2.4.16/homebrew.mxcl.redis.plist $HOME/Library/LaunchAgents/
# 	launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.redis.plist
# fi

# npm
curl https://npmjs.org/install.sh | sh
export NODE_PATH=/usr/local/lib/node_modules
echo -e "\n# npm" >> $HOME/.extra
echo "export NODE_PATH=/usr/local/lib/node_modules" >> $HOME/.extra
# Some also suggest adding '/usr/local/share/npm/bin' to $PATH

# RCEnvironment (http://www.rubicode.com/Software/RCEnvironment/)
# if [ ! -d $HOME/Library/PreferencePanes/RCEnvironment.prefPane ]; then
# 	hdiutil attach http://www.rubicode.com/Downloads/RCEnvironment-1.4.X.dmg
# 	mkdir -p $HOME/Library/PreferencePanes
# 	cp -R /Volumes/RCEnvironment-1.4.X/RCEnvironment.prefPane $HOME/Library/PreferencePanes
# else
# 	echo "[RCEnvironment] RCEnvironment PrefPane already installed"
# fi

### Desktop Apps ###

# Sequel Pro
if [ ! -d /Applications/Sequel\ Pro.app ]; then
	echo "Installing Sequel Pro"
	cd /tmp
	curl -O http://sequel-pro.googlecode.com/files/Sequel_Pro_$SEQUELPRO_VERSION.dmg
	cd -
	hdiutil attach /tmp/Sequel_Pro_$SEQUELPRO_VERSION.dmg
	cp -R /Volumes/Sequel\ Pro\ $SEQUELPRO_VERSION/Sequel\ Pro.app /Applications/
else
	echo "Sequel Pro is already installed"
fi

# Google Chrome
if [ ! -d /Applications/Google\ Chrome.app ]; then
	echo "Installing Google Chrome"
	hdiutil attach https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
	cp -R /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
	hdiutil detach /Volumes/Google\ Chrome
else
	echo "Chrome is already installed"
fi
echo "[Google Chrome] Don’t forget to install extensions: REST Console, Speed Tracer (https://chrome.google.com/webstore/category/home)"
echo

# Mozilla Firefox
if [ ! -d /Applications/Firefox.app ]; then
	echo "Installing Mozilla Firefox"
	hdiutil attach http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/$FIREFOX_VERSION/mac/en-US/Firefox%20$FIREFOX_VERSION.dmg
	cp -R /Volumes/Firefox/Firefox.app /Applications/
	hdiutil detach /Volumes/Firefox
	# Download and Install Firebug
	cd /tmp
	curl -LO https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi
	cd -
	/Applications/Firefox.app/Contents/MacOS/firefox -install-global-extension /tmp/addon-1843-latest.xpi
else
	echo "Firefox is already installed"
fi
echo "[Mozilla Firefox] Don't forget to enable Firebug extensions: Eventbug, NetExport, and FBTrace (https://getfirebug.com/swarms/Firefox-14.0/)"
echo

# Adobe Flash Player (and browser plugins)
echo "Installing Adobe Flash Player"
hdiutil attach http://fpdownload.macromedia.com/get/flashplayer/pdc/$FLASH_PLAYER_VERSION/install_flash_player_osx.dmg
echo "[Adobe Flash Player] Please follow the prompts. Waiting for Adobe Flash Player installer to quit..."
open -W /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app
hdiutil detach /Volumes/Flash\ Player
echo

# Sublime Text 2
if [ ! -d /Applications/Sublime\ Text\ 2.app ]; then
	echo "Installing Sublime Text 2"
	hdiutil attach http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20$SUBLIME_TEXT_2_VERSION.dmg
	cp -R /Volumes/Sublime\ Text\ 2/Sublime\ Text\ 2.app /Applications/
	# Enable CLI tool
	ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
else
	echo "Sublime Text 2 is already installed"
fi

# TextMate
if [ ! -d /Applications/TextMate.app ]; then
	echo "Installing TextMate"
	cd /tmp
	curl -O http://download.macromates.com/TextMate_$TEXTMATE_VERSION.zip
	unzip /tmp/TextMate_$TEXTMATE_VERSION.zip -d /Applications
	cd -
else
	echo "TextMate is already installed"
fi

# Dropbox
if [ ! -d /Applications/Dropbox.app ]; then
	echo "Installing Dropbox"
	cd /tmp
	curl -O http://dl-web.dropbox.com/u/17/b/Dropbox%20$DROPBOX_VERSION.dmg
	cd -
	hdiutil attach /tmp/Dropbox%20$DROPBOX_VERSION.dmg
	echo
	echo "[Dropbox] Please follow the prompts. Waiting for Dropbox installer to quit..."
	echo
	open -W /Volumes/Dropbox\ Installer/Dropbox.app
	hdiutil detach /Volumes/Dropbox\ Installer
else
	echo "Dropbox is already installed"
fi

# 1Password
if [ ! -d /Applications/1Password.app ]; then
	echo "Installing 1Password"
	cd /tmp
	curl -O https://d13itkw33a7sus.cloudfront.net/dist/1P/mac/1Password-$ONEPASSWORD_VERSION.zip
	unzip /tmp/1Password-$ONEPASSWORD_VERSION.zip -d /Applications
	cd -
else
	echo "1Password is already installed"
fi

# Adium
if [ ! -d /Applications/Adium.app ]; then
	echo "Installing Adium"
	hdiutil attach http://iweb.dl.sourceforge.net/project/adium/Adium_$ADIUM_VERSION.dmg
	cp -R /Volumes/Adium\ $ADIUM_VERSION/Adium.app /Applications/
else
	echo "Adium is already installed"
fi

