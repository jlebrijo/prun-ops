namespace :rails do
  task :prepare do
    on roles :all do
      execute <<-EOBLOCK
        echo gem: --no-ri --no-rdoc > /root/.gemrc
        gem install bundler
        gem install rack -v 1.6.0
        gem install thin -v 1.6.3
        thin install
        /usr/sbin/update-rc.d -f thin defaults
      EOBLOCK
      execute 'apt-get install -y imagemagick libmagickwand-dev'
    end
  end
end