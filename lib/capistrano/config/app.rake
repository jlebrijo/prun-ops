namespace :app do

  task :prepare do
    on roles :web do
      template 'app_init.sh', "/etc/init.d/#{fetch :application}"
      execute <<-EOBLOCK
        sudo thin config -C /etc/thin/#{fetch :application}.yml -c /var/www/#{fetch :application}/current -l log/thin.log -e #{fetch :stage} --servers 1 --port 3000
        sudo chmod a+x /etc/init.d/#{fetch :application}
        sudo update-rc.d #{fetch :application} defaults
        sudo systemctl daemon-reload
      EOBLOCK
    end
  end

  task :db_prepare do
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

  task :test do
  end

end