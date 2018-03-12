namespace :postgres do
  task :install do
    stage = fetch(:stage).to_s
    config   = Rails.configuration.database_configuration
    version = config[stage]["version"]
    username = config[stage]["username"]
    password = config[stage]["password"]

    on roles :all do
      execute <<-EOBLOCK
          sudo add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
          wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
          sudo apt-get update
          export LANGUAGE=en_US.UTF-8
          sudo apt-get -y install postgresql-client-#{version} libpq-dev
      EOBLOCK
    end

    on roles :db do
      execute <<-EOBLOCK
        sudo apt-get -y install postgresql-#{version} libpq-dev
      EOBLOCK

      execute <<-EOBLOCK
        sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/#{version}/main/postgresql.conf
        sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/#{version}/main/pg_hba.conf
        sudo sed -i "s/host    all             all             127.0.0.1/32            md5/host    all             all             all                     md5/" /etc/postgresql/#{version}/main/pg_hba.conf
        sudo sed -i "s/ssl = true/ssl = false/" /etc/postgresql/#{version}/main/postgresql.conf
        sudo service postgresql restart
      EOBLOCK

      ## Rewrite postgres password:
      execute <<-EOBLOCK
        sudo -u postgres psql -c "ALTER USER #{username} WITH PASSWORD '#{password}';"
      EOBLOCK

      invoke 'postgres:restart'
    end
  end

  %w(start stop restart).each do |action|
    desc "PostgreSQL"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service postgresql #{action}"
      end
    end
  end
end