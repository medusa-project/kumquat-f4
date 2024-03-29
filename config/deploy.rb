# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'kumquat'
set :repo_url, 'https://github.com/medusa-project/kumquat.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :home, '/home/kumquat'
set :deploy_to, "#{fetch(:home)}/kumquat-capistrano"
set :bin, "#{fetch(:home)}/bin"
# we have defined a UIUC-specific environment to keep the production
# environment brand-free for the benefit of other users.
set :rails_env, 'uiuc_production'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push(
                     'config/database.yml', 'config/kumquat.yml',
                     'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push(
                    'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
                    'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before :publishing, :stop_application

  task :stop_application do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{fetch(:bin)} ; ./stop-rails"
    end
  end

  task :start_application do
    on roles(:app), in: :sequence, wait: 5 do
      execute "cd #{fetch(:bin)} ; ./start-rails"
    end
  end

  after :publishing, :start_application

end
