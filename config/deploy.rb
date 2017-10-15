lock '3.4.1'

#set :rbenv_type, :system # or :system, depends on your rbenv setup
#set :rbenv_ruby, '2.4.1'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#set :rbenv_roles, :all # default value

set :application, 'imgclass'
set :repo_url, 'git@github.com:asfarley/imgclass.git' # Edit this to match your repository
set :branch, 'master'
set :deploy_to, '/srv/imgclass'
set :pty, false
#set :linked_files, %w{config/database.yml config/application.yml}
#set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}
set :keep_releases, 5
#set :rvm_type, :user
#set :rvm_ruby_version, 'jruby-1.7.19' # Edit this if you are using MRI Ruby

#set :puma_rackup, -> { File.join(current_path, 'config.ru') }
#set :puma_state, "#{shared_path}/tmp/pids/puma.state"
#set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
#set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"    #accept array for multi-bind
#set :puma_conf, "#{shared_path}/puma.rb"
#set :puma_access_log, "#{shared_path}/log/puma_error.log"
#set :puma_error_log, "#{shared_path}/log/puma_access.log"
#set :puma_role, :app
#set :puma_threads, [0, 8]
#set :puma_workers, 0
#set :puma_worker_timeout, nil
#set :puma_init_active_record, true
#set :puma_preload_app, false


namespace :deploy do
  namespace :db do
    desc "Load the database schema if needed"
    task load: [:set_rails_env] do
      on primary :db do
        if not test(%Q[[ -e "#{shared_path.join(".schema_loaded")}" ]])
          within release_path do
            with rails_env: fetch(:rails_env) do
              execute :rake, "db:environment:set"
              execute :rake, "db:schema:load"
              execute :touch, shared_path.join(".schema_loaded")
            end
          end
        end
      end
    end
  end

  before "deploy:migrate", "deploy:db:load"
end
