
if Rails.application.config.respond_to? :backup_dirs
  set :backup_dirs, Rails.application.config.backup_dirs
else
  set :backup_dirs, []
end

namespace :deploy do

  %w(start stop restart).each do |action|
    desc "#{action.capitalize} application"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service #{fetch :application} #{action}"
      end
    end
  end

  after :publishing, :restart

  desc 'Deploy app for first time'
  task :cold do
    invoke 'deploy:starting'
    invoke 'deploy:started'
    invoke 'deploy:updating'
    invoke 'bundler:install'
    invoke 'deploy:db_reset' # This replaces deploy:migrations
    invoke 'deploy:compile_assets'
    invoke 'deploy:normalize_assets'
    invoke 'deploy:publishing'
    invoke 'deploy:published'
    invoke 'deploy:finishing'
    invoke 'deploy:finished'
  end

  desc 'Setup database'
  task :db_reset do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:create'
          execute :rake, 'db:schema:load'
          execute :rake, 'db:seed'
        end
      end
    end
  end
  desc 'Seed database'
  task :db_seed do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:seed'
        end
      end
    end
  end
end
