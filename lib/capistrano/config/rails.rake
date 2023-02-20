namespace :rails do
  task :prepare do
    on roles :all do
      execute <<-EOBLOCK
        source "/etc/profile.d/rvm.sh"
        echo gem: --no-ri --no-rdoc | sudo tee -a /etc/gemrc
        gem install bundler
        gem install rack #-v 1.6.0
      EOBLOCK
      execute "#{apt_nointeractive} imagemagick libmagickwand-dev"

      execute <<-EOBLOCK
        sudo mkdir -p /var/www/#{fetch :application}
        sudo chown #{host.user}:#{host.user} /var/www/#{fetch :application}
      EOBLOCK

    end
  end
end