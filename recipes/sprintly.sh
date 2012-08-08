#!/bin/bash

DEFAULT_PROJECT_DIR=$HOME/Projects/Sprint.ly/git

PROJECT_DIR=$DEFAULT_PROJECT_DIR
newdir=false
while ! $newdir
do
	read -e -p "Where would you like to clone the Sprint.ly Github repos? [$DEFAULT_PROJECT_DIR]: " PROJECT_DIR
	if [ "$PROJECT_DIR" = "" ]
	then
		PROJECT_DIR=$DEFAULT_PROJECT_DIR
	fi

	if [[ -d $PROJECT_DIR && "$(ls -A $PROJECT_DIR)" ]]
	then
		echo "The directory '$PROJECT_DIR' is not empty. Please use a new path or an empty directory."
		newdir=false
	elif [ -f $PROJECT_DIR ]
	then
		echo "'$PROJECT_DIR' is a file. Please use a new path or an empty directory."
		newdir=false
	elif [[ ! -f $PROJECT_DIR ]]
	then
		newdir=true
	fi
done

mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Ask for some settings up front
read -p "Enter your AWS Access Key: " AWS_ACCESS_KEY
read -p "Enter your AWS Secret: " AWS_SECRET

# Setup snowbird (Sprint.ly website)
git clone git@github.com:sagely/sprint.ly.git

# Create default overrides
cat >> $PROJECT_DIR/sprint.ly/snowbird/overrides.m4 << EOF
\# Here are your generated override settings for the Sprint.ly website.
\# Please double check the values before continuing.

define(\`__AWS_KEY__\', \`$AWS_ACCESS_KEY\')
define(\`__AWS_SECRET__\', \`$AWS_SECRET\')
define(\`__DATABASE_USER__\', \`root\')
define(\`__DATABASE_PASSWORD__\', \`\')
define(\`__DATABASE_HOST__\', \`localhost\')
define(\`__DATABASE_PORT__\', \`3306\')
define(\`__DATABASE_ENGINE__\', \`mysql\')
define(\`__DATABASE_NAME__\', \`sprintly_local\')
define(\`__DATABASE_USER__\', \`root\')
EOF

# Give a chance to modify the override values
vim $PROJECT_DIR/sprint.ly/snowbird/overrides.m4

echo "Building project..."
cd $PROJECT_DIR/sprint.ly/snowbird
make
./manage.py syncdb
./manage.py runserver 127.0.0.1:8000
echo "Sprint.ly should now be available in your browser at: http://127.0.0.1:8000"

# Configure ssh
# 1) Generate SSH sig
# 2) Save sig files to ~/.ssh/id_rsa_sprintly, ~/.ssh/id_rsa_sprintly.pub
# 3) ~/.ssh/config