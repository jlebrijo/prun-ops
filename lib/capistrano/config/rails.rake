namespace :rails do
  task :prepare do
    on roles :all do
      execute <<-EOBLOCK
        echo gem: --no-ri --no-rdoc | sudo tee -a /etc/gemrc
        sudo gem install bundler
        sudo gem install rack -v 1.6.0
        sudo gem install thin -v 1.6.3
        sudo thin install
        sudo /usr/sbin/update-rc.d -f thin defaults
      EOBLOCK
      execute 'sudo apt-get install -y imagemagick libmagickwand-dev'

      execute <<-EOBLOCK
        sudo mkdir -p /var/www/#{fetch :application}
        sudo chown #{host.user}:#{host.user} /var/www/#{fetch :application}
      EOBLOCK

    end
  end
end