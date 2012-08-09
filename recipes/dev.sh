# App Versions
FIREFOX_VERSION='14.0.1'
FLASH_PLAYER_VERSION='11.3.300.268'
SUBLIME_TEXT_2_VERSION='2.0.1'
TEXTMATE_VERSION='1.5.11_r1635'
DROPBOX_VERSION='1.4.12'
ADIUM_VERSION='1.5.2'

### CLI Apps ###

# We're going to need this later
mkdir -p $HOME/Library/LaunchAgents

# "Hub" for Github (http://defunkt.io/hub/)
brew install hub

# Python: Install pip, virtualenv, and virtualenvwrapper
easy_install pip
pip install virtualenv
pip install virtualenvwrapper
#if [ ! -z "$WORKON_HOME" ]; then
if grep -q -e "^WORKON_HOME=" $HOME/.extra; then
	echo "\$WORKON_HOME already set in '~/.extra'"
else
	echo -e "\n# virtualenvwrapper" >> $HOME/.extra
	echo "export WORKON_HOME=~/.virtualenvs" >> $HOME/.extra
	echo "export PROJECT_HOME=~/Projects" >> $HOME/.extra
	echo "source virtualenvwrapper_lazy.sh" >> $HOME/.extra
fi
mkdir -p $HOME/.virtualenvs
source $HOME/.extra
source virtualenvwrapper.sh

exit 0

# Install MySQL and set to launch at startup
brew install mysql
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
cp /usr/local/Cellar/mysql/5.5.25a/homebrew.mxcl.mysql.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.mysql.plist
# TODO: Ask for MySQL root Password:
#/usr/local/Cellar/mysql/5.5.25a/bin/mysqladmin -u root password 'new-password'
#/usr/local/Cellar/mysql/5.5.25a/bin/mysqladmin -u root -h Animal Retina Pro password 'new-password'

# Memcached
brew install memcached
cp /usr/local/Cellar/memcached/1.4.14/homebrew.mxcl.memcached.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.memcached.plist

# Redis
brew install redis
cp /usr/local/Cellar/redis/2.4.16/homebrew.mxcl.redis.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.redis.plist

# npm
#curl https://npmjs.org/install.sh | sh
#export NODE_PATH=/usr/local/lib/node_modules

# RCEnvironment (http://www.rubicode.com/Software/RCEnvironment/)
# if [ ! -d $HOME/Library/PreferencePanes/RCEnvironment.prefPane ]; then
# 	hdiutil attach http://www.rubicode.com/Downloads/RCEnvironment-1.4.X.dmg
# 	mkdir -p $HOME/Library/PreferencePanes
# 	cp -R /Volumes/RCEnvironment-1.4.X/RCEnvironment.prefPane $HOME/Library/PreferencePanes
# else
# 	echo "[RCEnvironment] RCEnvironment PrefPane already installed"
# fi

### Desktop Apps ###

# Google Chrome
if [ ! -d /Applications/Google\ Chrome.app ]; then
	echo "Installing Google Chrome"
	hdiutil attach https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg
	cp -R /Volumes/Google\ Chrome/Google\ Chrome.app /Applications/
	hdiutil detach /Volumes/Google\ Chrome
else
	echo "[Google Chrome] Chrome is already installed"
fi
echo "[Google Chrome] Don’t forget to install extensions: REST Console, Speed Tracer (https://chrome.google.com/webstore/category/home)"

# Mozilla Firefox
if [ ! -d /Applications/Firefox.app ]; then
	echo "\nInstalling Mozilla Firefox"
	hdiutil attach http://download.cdn.mozilla.net/pub/mozilla.org/firefox/releases/$FIREFOX_VERSION/mac/en-US/Firefox%20$FIREFOX_VERSION.dmg
	cp -R /Volumes/Firefox/Firefox.app /Applications/
	hdiutil detach /Volumes/Firefox
	cd /tmp
	curl -LO https://addons.mozilla.org/firefox/downloads/latest/1843/addon-1843-latest.xpi
	cd -
	/Applications/Firefox.app/Contents/MacOS/firefox -install-global-extension /tmp/addon-1843-latest.xpi
else
	echo "[Mozilla Firefox] Firefox is already installed"
fi
echo "[Mozilla Firefox] Don't forget to enable Firebug extensions: Eventbug, NetExport, and FBTrace (https://getfirebug.com/swarms/Firefox-14.0/)"

# Adobe Flash Player (and browser plugins)
echo "\nInstalling Adobe Flash Player"
hdiutil attach http://fpdownload.macromedia.com/get/flashplayer/pdc/$FLASH_PLAYER_VERSION/install_flash_player_osx.dmg
echo "[Adobe Flash Player] Please follow the prompts. Waiting for Adobe Flash Player installer to quit..."
open -W /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app
hdiutil detach /Volumes/Flash\ Player

# Sublime Text 2
if [ ! -d /Applications/Sublime\ Text\ 2.app ]; then
	echo "\nInstalling Sublime Text 2"
	hdiutil attach http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20$SUBLIME_TEXT_2_VERSION.dmg
	cp -R /Volumes/Sublime\ Text\ 2/Sublime\ Text\ 2.app /Applications/
	ln -s "/Applications/Sublime Text 2.app/Contents/SharedSupport/bin/subl" $HOME/bin/subl
else
	echo "[Sublime Text 2] Sublime Text 2 is already installed"
fi

# TextMate
if [ ! -d /Applications/TextMate.app ]; then
	echo "\nInstalling TextMate"
	cd /tmp
	curl -O http://download.macromates.com/TextMate_$TEXTMATE_VERSION.zip
	unzip /tmp/TextMate_$TEXTMATE_VERSION.zip -d /Applications
	cd -
else
	echo "[TextMate] TextMate is already installed"
fi


# Dropbox
if [ ! -d /Applications/Dropbox.app ]; then
	echo "\nInstalling Dropbox"
	cd /tmp
	curl -O http://dl-web.dropbox.com/u/17/b/Dropbox%20$DROPBOX_VERSION.dmg
	hdiutil attach Dropbox%20$DROPBOX_VERSION.dmg
	cd -
	echo "[Dropbox] Please follow the prompts. Waiting for Dropbox installer to quit..."
	open -W /Volumes/Dropbox\ Installer/Dropbox.app
	hdiutil detach /Volumes/Dropbox\ Installer
else
	echo "[Dropbox] Dropbox is already installed"
fi

# Adium
if [ ! -d /Applications/Adium.app ]; then
	echo "\nInstalling Adium"
	hdiutil attach http://iweb.dl.sourceforge.net/project/adium/Adium_$ADIUM_VERSION.dmg
	cp -R /Volumes/Adium\ $ADIUM_VERSION/Adium.app /Applications/
else
	echo "[Adium] Adium is already installed"
fi

