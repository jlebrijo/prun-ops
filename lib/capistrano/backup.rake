# frozen_string_literal: true

namespace :backup do
  desc "Restore data from git repo, last backup by default"
  task :restore, :tag do |_task, args|
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, "backup:restore #{args[:tag]}"
        end
      end
    end
  end
end

desc "Backup data to a git repo, tagging it into the git repo"
task :backup, :tag do |_task, args|
  on roles(:app) do
    within release_path do
      with rails_env: "production" do
        execute :rake, "backup #{args[:tag]}"
      end
    end
  end
end

namespace :pull do
  desc "Pull data (db/files) from remote (i.e: production) application."
  task :data do
    invoke "pull:files"
    invoke "pull:db"
  end

  desc "Pull db: Hot backup, download and restore of the stage database"
  task :db do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, "db:backup"
          execute "mv #{release_path}/tmp/db.sql /tmp/db.sql"
          download! "/tmp/db.sql", "tmp/db.sql"
        end
        run_locally do
          # Don't raise error if rails version < 5
          begin
            execute "rails db:environment:set RAILS_ENV=development"
          rescue StandardError; end
          rake "db:restore"
        end
      end
    end
  end

  desc "Pull files uploaded"
  task :files do
    on roles(:app) do |host|
      run_locally do
        debug ":   Pulling Files from #{fetch(:stage)} ..."
        if fetch(:backup_dirs).any?
          fetch(:backup_dirs).each do |dir|
            execute "rm -r #{dir}"
            execute "scp -r -P #{host.port} #{host.user}@#{host.hostname}:#{current_path}/#{dir} #{dir}"
          end
        else
          error ":    Set key :backup_dirs to know which ones to pull"
        end
      end
    end
  end
end
