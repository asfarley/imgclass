#
# imgclass.com development environment provisioning script
#
# Jan 7, 2018
#
# This script:
# * Installs dependencies
# * Installs Rails, Ruby, rbenv, nodejs
#
#
# Tested on Ubuntu 16.04 instances in VMWare Player.
#

# Store initial directory for use later
INITIAL_DIRECTORY="$PWD"

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

#bundle install --without development test
#RAILS_ENV=production rails db:create
#RAILS_ENV=production rails db:schema:load
#RAILS_ENV=production rails db:seed
