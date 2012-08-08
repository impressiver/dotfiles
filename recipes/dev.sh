# We're going to need this later
mkdir -p $HOME/Library/LaunchAgents

# "Hub" for Github (http://defunkt.io/hub/)
brew install hub

# Python: Install pip and virtualenv
easy_install pip
pip install virtualenv

# Install MySQL and set to launch at startup
brew install mysql
unset TMPDIR
mysql_install_db --verbose --user=`whoami` --basedir="$(brew --prefix mysql)" --datadir=/usr/local/var/mysql --tmpdir=/tmp
cp /usr/local/Cellar/mysql/5.5.25a/homebrew.mxcl.mysql.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.mysql.plist

# Memcached
brew install memcached
cp /usr/local/Cellar/memcached/1.4.14/homebrew.mxcl.memcached.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.memcached.plist

# Redis
brew install redis
cp /usr/local/Cellar/redis/2.4.15/homebrew.mxcl.redis.plist $HOME/Library/LaunchAgents/
launchctl load -w $HOME/Library/LaunchAgents/homebrew.mxcl.redis.plist

# RCEnvironment (http://www.rubicode.com/Software/RCEnvironment/)
hdiutil attach http://www.rubicode.com/Downloads/RCEnvironment-1.4.X.dmg
mkdir -p $HOME/Library/PreferencePanes
cp -R /Volumes/RCEnvironment-1.4.X/RCEnvironment.prefPane $HOME/Library/PreferencePanes

