sudo adduser deploy
sudo adduser deploy sudo
su deploy

sudo apt-get update -y
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nodejs libpq-dev nginx -y

cd
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile

git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile

rbenv install 2.4.1
rbenv global 2.4.1
ruby -v

gem install bundler

rbenv rehash

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

gem install rails -v 5.1.3

rbenv rehash

rails -v # Rails 5.1.3

git clone git://github.com/dcarley/rbenv-sudo.git ~/.rbenv/plugins/rbenv-sudo

sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update -y
sudo apt-get install -y nginx-extras passenger
sudo sed -i 's|#include /etc/nginx/passenger.conf|include /etc/nginx/passenger.conf|' /etc/nginx/nginx.conf
sudp cp ./accessory/imgclass.conf /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo service nginx restart
