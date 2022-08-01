namespace :ubuntu do
  task :install do
    on roles :all do
      execute 'sudo apt-get -y update'
      # Pre-requirements
      execute <<-EOBLOCK
        sudo apt-get install -y git build-essential libsqlite3-dev libssl-dev gawk g++ vim
        sudo apt-get install -y libreadline6-dev libyaml-dev sqlite3 autoconf libgdbm-dev
        sudo apt-get install -y libcurl4 libcurl3-gnutls libcurl4-openssl-dev 
        sudo apt-get install -y libncurses5-dev automake libtool bison pkg-config libffi-dev
        sudo apt-get install -y software-properties-common
      EOBLOCK
    end
  end
end
