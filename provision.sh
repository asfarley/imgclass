#
# imgclass.com provisioning script
#
# Oct 15, 2017
#
# This script:
# * Installs dependencies
# * Installs Rails, Ruby, rbenv, nodejs, nginx, passenger
# * Configures nginx to serve this application
#
#
# Tested on Ubuntu 16.04 t2.micro instances.
#
#
# Before running this script, create a deploy user:
#
INITIAL_DIRECTORY="$(dirname "$0")"

sudo adduser deploy --gecos ""
sudo adduser deploy sudo
su deploy

# Copy over the authorized public keys in the ubuntu user's .ssh directory
cd ~
mkdir .ssh
sudo cp /home/ubuntu/.ssh/authorized_keys .ssh/
chmod 700 .ssh
sudo chown deploy .ssh/authorized_keys
sudo chmod 600 .ssh/authorized_keys

# Create deployment folder for Capistrano
sudo mkdir /var/www
sudo chown deploy /var/www

# Update and get dependencies
sudo apt-get update -y
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs libpq-dev nginx -y

# Install rbenv
cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

#  Install rbenv plugin ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

# Install ruby
rbenv install 2.4.1
rbenv global 2.4.1
ruby -v

# Install bundler
gem install bundler

rbenv rehash

# Install nodejs
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install rbenv-sudo
git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

# Install passenger and nginx
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update -y
sudo apt-get install -y nginx-extras passenger

# Configure passenger/nginx
sudo sed -i 's|# include /etc/nginx/passenger.conf|include /etc/nginx/passenger.conf|' /etc/nginx/nginx.conf
sudo sed -i 's|#include /etc/nginx/passenger.conf|include /etc/nginx/passenger.conf|' /etc/nginx/nginx.conf
cd $INITIAL_DIRECTORY
sudo cp ./accessory/imgclass.conf /etc/nginx/sites-enabled/

# Set up Rails
bundle install --without development test
sudo mkdir /var/db
sudo chown deploy /var/db
source ~/.bash_profile
RAILS_ENV=production rails db:create
RAILS_ENV=production rails db:schema:load
RAILS_ENV=production rails db:seed
sudo rm /etc/nginx/sites-enabled/default

# Restart
sudo service nginx restart

# At this point, on your workstation you may use:
# >> cap production deploy
# which will push the code to the server.
