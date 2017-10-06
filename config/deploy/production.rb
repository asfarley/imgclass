server '35.165.73.193', user: 'deploy', roles: %w{web app db}

set :branch, 'master' #if ENV['BRANCH']
set :puma_env, fetch(:rack_env, fetch(:rails_env, 'production'))
