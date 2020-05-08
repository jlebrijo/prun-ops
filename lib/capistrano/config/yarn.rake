namespace :yarn do
  task :install do
    on roles :app do
      execute <<-EOBLOCK
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
             echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
        apt-get -qq update && apt-get install -y yarn
        yarn install --check-files
      EOBLOCK
    end
  end
end