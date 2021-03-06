#!/bin/bash

#
# TODO: Ensure the following are installed: git, mysql, node, virtualenv, virtualenvwrapper
#

if [ -f $HOME/.extra ]; then
	source $HOME/.extra
fi

DEFAULT_GIT_AUTHOR_NAME=$GIT_AUTHOR_NAME
DEFAULT_GIT_AUTHOR_EMAIL=$GIT_AUTHOR_EMAIL

DEFAULT_PROJECT_DIR=$HOME/Projects/Sprint.ly/git
DEFAULT_DATABASE_NAME='sprintly_local'
DEFAULT_DATABASE_USER='root'
DEFAULT_DATABASE_PASSWORD=''
DEFAULT_DATABASE_HOST='localhost'
DEFAULT_DATABASE_PORT='3306'

newdir=false
while ! $newdir
do
	read -e -p "Where would you like to clone the Sprint.ly Github repos? [$DEFAULT_PROJECT_DIR] " PROJECT_DIR
	PROJECT_DIR=${PROJECT_DIR:-$DEFAULT_PROJECT_DIR}

	if [[ -d $PROJECT_DIR && "$(ls -A $PROJECT_DIR)" ]]
	then
		echo "The directory '$PROJECT_DIR' is not empty. Please use a new path or an empty directory."
		newdir=false
	elif [ -f $PROJECT_DIR ]
	then
		echo "'$PROJECT_DIR' is a file. Please enter a new path or an empty directory."
		newdir=false
	elif [[ ! -f $PROJECT_DIR ]]
	then
		newdir=true
	fi
done

# Create the project directory
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Ask for personal settings up front
read -p "Enter your full name: ($DEFAULT_GIT_AUTHOR_NAME) " GIT_AUTHOR_NAME
read -p "Enter your Sprint.ly email address: ($DEFAULT_GIT_AUTHOR_EMAIL) " GIT_AUTHOR_EMAIL
read -p "Enter your Sprint.ly API key (https://sprint.ly/account/profile/): " SPRINTLY_API_KEY

read -p "Enter your AWS Access Key: " AWS_ACCESS_KEY
read -p "Enter your AWS Secret: " AWS_SECRET

read -p "Enter MySQL database name (wil be created if it doesn't exit): ['$DEFAULT_DATABASE_NAME'] " DATABASE_NAME
read -p "Enter MySQL user: ['$DEFAULT_DATABASE_USER'] " DATABASE_USER
read -p "Enter MySQL password: ['$DEFAULT_DATABASE_PASSWORD'] " DATABASE_PASSWORD
read -p "Enter MySQL host: ['$DEFAULT_DATABASE_HOST'] " DATABASE_HOST
read -p "Enter MySQL port: ['$DEFAULT_DATABASE_PORT'] " DATABASE_PORT

gitauthor=${GIT_AUTHOR_NAME:-$DEFAULT_GIT_AUTHOR_NAME}
gitemail=${GIT_AUTHOR_EMAIL:-$DEFAULT_GIT_AUTHOR_EMAIL}

apikey=$SPRINTLY_API_KEY

dbname=${DATABASE_NAME:-$DEFAULT_DATABASE_NAME}
dbuser=${DATABASE_USER:-$DEFAULT_DATABASE_USER}
dbpass=${DATABASE_PASSWORD:-$DEFAULT_DATABASE_PASSWORD}
dbhost=${DATABASE_HOST:-$DEFAULT_DATABASE_HOST}
dbport=${DATABASE_PORT:-$DEFAULT_DATABASE_PORT}

# Generate a Sprint.ly ssh keypair
echo "Generating ssh keys for $GIT_AUTHOR_EMAIL ('~/.ssh/id_rsa_sprintly{.pub}')"
ssh-keygen -t rsa -f '$HOME/.ssh/id_rsa_sprintly' -C "$GIT_AUTHOR_EMAIL"
# TODO: Add HostName *.sprint.ly to ~/.ssh/config

# Install Sphinx
# TODO: brew install sphinx

# Install the Sprint.ly-Github CLI (https://github.com/nextbigsoundinc/Sprintly-GitHub)
echo "Installing Sprint.ly-Github CLI..."
curl -O https://raw.github.com/nextbigsoundinc/Sprintly-GitHub/master/sprintly
sudo python sprintly --install
sudo chown $(whoami):admin /usr/local/bin/sprintly
rm sprintly
mkdir -p $HOME/.sprintly
echo "{\"user\": \"$gitemail\", \"key\": \"$apikey\"}" > $HOME/.sprintly/sprintly.config
sprintly

echo "Adding alias 'run.ly' to '~/.extra'..."
#alias run.ly="cd.ly; workon snowbird; make settings.py; ./manage.py syncdb; ./manage.py migrate; ./manage.py runserver"

# Clone the project (Sprint.ly website)
git clone https://github.com/sprintly/sprint.ly.git
git clone https://github.com/sprintly/sprint.ly-services.git

if [ ! -d "$PROJECT_DIR/sprint.ly" ]; then
	echo "Failed to clone sprint.ly repo from 'https://github.com/sprintly/sprint.ly.git'"
	exit 1
fi

# Add symlink to services package
ln -s $PROJECT_DIR/sprint.ly-services/lookout $PROJECT_DIR/sprint.ly/snowbird/site-packages/lookout

# Configure and build Sprint.ly
cd "$PROJECT_DIR/sprint.ly"

# Set the Github author and email
git config user.name "$gitauthor"
git config user.email "$gitemail"

# Create default overrides file
###############################################################################
cat >> $PROJECT_DIR/sprint.ly/snowbird/overrides.m4 << EOF
# Here are your generated override settings for the Sprint.ly website.
# Please double check the values before continuing.

define(\`__AWS_KEY__', \`$AWS_ACCESS_KEY')
define(\`__AWS_SECRET__', \`$AWS_SECRET')
define(\`__DATABASE_NAME__', \`"$dbname"')
define(\`__DATABASE_USER__', \`$dbuser')
define(\`__DATABASE_PASSWORD__', \`$dbpass')
define(\`__DATABASE_HOST__', \`$dbhost')
define(\`__DATABASE_PORT__', \`$dbport')
define(\`__DATABASE_ENGINE__', \`mysql')
EOF
###############################################################################

# Give user a chance to modify the override values
$EDITOR $PROJECT_DIR/sprint.ly/snowbird/overrides.m4
# Now get rid of the comments so m4 won't pass them on
sed -i '.backup' '/^#.*$/d' $PROJECT_DIR/sprint.ly/snowbird/overrides.m4
rm $PROJECT_DIR/sprint.ly/snowbird/overrides.m4.backup

echo "Setting up virtual environment 'snowbird'..."
source /usr/local/share/python/virtualenvwrapper.sh
mkvirtualenv snowbird
workon snowbird

pip install -r $PROJECT_DIR/sprint.ly/snowbird/requirements-local.txt

echo "Creating database '$dbname'"
if [ -z "$dbpass" ]; then
	mysqladmin --user=$dbuser --password=$dbpass --host=$dbhost create $dbname
else
	mysqladmin --user=$dbuser --host=$dbhost create $dbname
fi

echo "Building project..."
cd $PROJECT_DIR/sprint.ly/snowbird
make all
./manage.py syncdb --noinput
./manage.py migrate
./manage.py createsuperuser
./manage.py runserver 127.0.0.1:8000 &
echo "Sprint.ly should now be available in your browser at: http://127.0.0.1:8000"

# Propane for Campfire
if [ ! -d /Applications/Propane.app ]; then
	cd /tmp
	curl -O http://propaneapp.com/appcast/Propane.zip
	unzip /tmp/Propane.zip -d /Applications
fi

# TODO:
# Add permissions for user to access created SQS queue (or change the code to set perms by default)
# Configure ssh
# 1) Generate SSH sig
# 2) Save sig files to ~/.ssh/id_rsa_sprintly, ~/.ssh/id_rsa_sprintly.pub
# 3) ~/.ssh/config