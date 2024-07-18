namespace :app do

  task :db_prepare do
    on roles(:app) do
      invoke 'deploy:starting'
      invoke 'deploy:started'
      invoke 'deploy:updating'
      invoke 'bundler:install'
      if Rails.application.config.respond_to? :backup_repo
        invoke 'backup:restore'
      else
        invoke 'deploy:db_create'
        invoke 'deploy:migrate'
        invoke 'deploy:db_seed'
      end
    end
  end

  task :test do
  end

end