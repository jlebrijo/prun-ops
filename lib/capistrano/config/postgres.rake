# frozen_string_literal: true

namespace :postgres do
  task :install do
    stage = fetch(:stage).to_s
    Rails.env = "production"
    config = Rails.configuration.database_configuration
    version = config["default"]["version"]

    on roles :all do
      execute <<-EOBLOCK
        #{apt_nointeractive} curl ca-certificates
        sudo install -d /usr/share/postgresql-common/pgdg
        sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
      EOBLOCK

      execute <<-EOBLOCK
        . /etc/os-release
        sudo sh -c "echo 'deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $VERSION_CODENAME-pgdg main' > /etc/apt/sources.list.d/pgdg.list"
        sudo apt -y update
        #{apt_nointeractive} postgresql-client-#{version} libpq-dev
      EOBLOCK
    end

    on roles :db do
      execute <<-EOBLOCK
      #{apt_nointeractive} postgresql-#{version} libpq-dev
      EOBLOCK

      execute <<-EOBLOCK
        sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/#{version}/main/postgresql.conf
        sudo sed -i "s/local   all             all                                     peer/local   all             all                                     md5/" /etc/postgresql/#{version}/main/pg_hba.conf
        sudo sed -i "s/host    all             all             127.0.0.1\\/32            scram-sha-256/host    all             all             all                     scram-sha-256/" /etc/postgresql/#{version}/main/pg_hba.conf
        sudo sed -i "s/ssl = on/ssl = off/" /etc/postgresql/#{version}/main/postgresql.conf
        sudo service postgresql restart
      EOBLOCK

      ## Rewrite postgres password:
      if Rails.version.to_i >= 8
        %w[primary cable queue cache].each do |db|
          create_db(username: config[stage][db]["username"], password: config[stage][db]["password"],
                    database: config[stage][db]["database"])
        end
      else
        create_db(username: config[stage]["username"], password: config[stage]["password"],
                  database: config[stage]["database"])
      end

      invoke "postgres:restart"
    end
  end

  %w[start stop restart].each do |action|
    desc "PostgreSQL"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service postgresql #{action}"
      end
    end
  end
end

def create_db(username:, password:, database:)
  execute <<-EOBLOCK
            sudo -u postgres psql -c "CREATE USER #{username} WITH PASSWORD '#{password}';"
            sudo -u postgres psql -c "create database #{database};"
            sudo -u postgres psql -c "grant all privileges on database #{database} to #{username};"
            sudo -u postgres psql -c "alter user #{username} with superuser;"
  EOBLOCK
end
