
require_relative "./application.rb"
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
        execute "service #{fetch :application} #{action}"
      end
    end
  end

  after :publishing, :restart
end


namespace :db do
  desc 'First DDBB setup'
  task :setup do
    on roles(:all) do
      within release_path do
        with rails_env: fetch(:stage) do
          execute :rake, 'db:schema:load'
          execute :rake, 'db:seed'
        end
      end
    end
  end
end