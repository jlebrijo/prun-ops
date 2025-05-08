# frozen_string_literal: true

if defined?(Rails) && Rails.application.config.respond_to?(:backup_dirs)
  set :backup_dirs, Rails.application.config.backup_dirs
else
  set :backup_dirs, []
end

namespace :deploy do
  %w[start stop restart].each do |action|
    desc "#{action.capitalize} application"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service #{fetch :application} #{action}"
      end
    end
  end

  task :upload_linked_files do
    on roles :app do
      shared = "/var/www/#{fetch :application}/shared"
      fetch(:linked_files)&.each do |f|
        execute "mkdir -p #{shared}/#{File.dirname f}"
        upload! f, "#{shared}/#{f}"
      end
    end
  end

  after :publishing, :upload_linked_files
  # after :publishing, :restart

  desc "Create database"
  task :db_create do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rails, "db:create"
        end
      end
    end
  end
  desc "Create drop"
  task :db_drop do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rails, "db:drop"
        end
      end
    end
  end
  desc "Setup database"
  task :db_reset do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rails, "db:schema:load"
          execute :rails, "db:seed"
        end
      end
    end
  end
  desc "Seed database"
  task :db_seed do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rails, "db:seed"
        end
      end
    end
  end
end
