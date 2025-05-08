# frozen_string_literal: true

namespace :redis do
  task :install do
    on roles :app do
      execute <<-EOBLOCK
        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
        sudo apt-get update
        #{apt_nointeractive} redis
        systemctl enable redis-server
        service redis-server start
      EOBLOCK
    end
  end
end
