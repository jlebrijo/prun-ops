namespace :ubuntu do
  task :prepare do
    on roles :all do
      execute 'sudo apt-get -y update'
      # Pre-requirements
      execute <<-EOBLOCK
        #{apt_nointeractive} git build-essential libsqlite3-dev libssl-dev gawk g++ vim 
        #{apt_nointeractive} libssl-dev libreadline-dev libgdbm-dev openssl
        #{apt_nointeractive} libreadline6-dev libyaml-dev sqlite3 autoconf libgdbm-dev
        #{apt_nointeractive} libcurl4 libcurl3-gnutls libcurl4-openssl-dev 
        #{apt_nointeractive} libncurses5-dev automake libtool bison pkg-config libffi-dev
        #{apt_nointeractive} software-properties-common gnupg2
      EOBLOCK
    end
  end
end
