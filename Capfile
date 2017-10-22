# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/passenger"

require "capistrano/bundler"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#   https://github.com/capistrano/passenger
#
# require "capistrano/rvm"
require "capistrano/rbenv"

# require "capistrano/chruby"
# require "capistrano/bundler"
require "capistrano/rails/assets"
# require "capistrano/rails/migrations"
# require "capistrano/passenger"

desc "Prepare database on first deployment"
task :prepare_database do
  on roles(:all) do |host|
      execute "cd /var/www/imgclass/current/ && RAILS_ENV=production rails db:create"
      execute "cd /var/www/imgclass/current/ && RAILS_ENV=production rails db:schema:load"
      execute "cd /var/www/imgclass/current/ && RAILS_ENV=production rails db:seed"
  end
end

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
