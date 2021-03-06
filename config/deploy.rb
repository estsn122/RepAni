lock '~> 3.14.1'
set :application, 'RepAni'
set :repo_url, 'git@github.com:estsn122/RepAni.git'
set :user, 'yuya'
# Default branch is :master
# deploy時にブランチを選択したい場合は、以下のコメント部分を外す
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
set :deploy_to, '/var/www/RepAni'
set :linked_files, %w[config/master.key config/database.yml]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets public/system vendor/bundle]
set :rbenv_ruby, File.read('.ruby-version').strip
set :puma_threds, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{shared_path}/log/puma.access.log"
set :puma_preload_app, true

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end
  before :start, :make_dirs
end
namespace :deploy do
  desc 'upload important files'
  task :upload do
    on roles(:app) do
      sudo :mkdir, '-p', "#{shared_path}/config"
      sudo %(chown -R #{fetch(:user)}.#{fetch(:user)} /var/www/#{fetch(:application)})
      sudo :mkdir, '-p', '/etc/nginx/sites-enabled'
      sudo :mkdir, '-p', '/etc/nginx/sites-available'
      # upload!('config/database.yml', "#{shared_path}/config/database.yml")
      upload!('config/master.key', "#{shared_path}/config/master.key")
    end
  end
  desc 'Create database'
  task :db_create do
    on roles(:db) do
      with rails_env: fetch(:rails_env) do
        within release_path do
          execute :bundle, :exec, :rake, 'db:create'
        end
      end
    end
  end
  desc 'webpacker'
  task :webpacker do
    on roles(:app) do
      within release_path do
        execute :yarn, :install, '--check-files'
        execute :rails, 'webpacker:compile'
      end
    end
  end
  before :starting, :upload
  before 'check:linked_files', 'puma:nginx_config'
end
after 'deploy:published', 'nginx:restart'
before 'deploy:migrate', 'deploy:db_create'
after 'nginx:restart', 'deploy:webpacker'
