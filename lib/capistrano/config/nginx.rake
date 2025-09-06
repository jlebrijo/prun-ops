# frozen_string_literal: true

namespace :nginx do
  task :install do
    on roles :web, :api do
      execute "#{apt_nointeractive} nginx"
      execute 'sudo sed -i "s/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 64/" /etc/nginx/nginx.conf'
      template "vhost.conf", "/etc/nginx/conf.d/vhost.conf"

      invoke "nginx:restart"
    end
  end

  task :cert do
    on roles(:web, :api) do |host|
      run_locally do
        run_in host, <<-EOBLOCK
          sudo apt update
          sudo apt install certbot python3-certbot-nginx -y
          sudo certbot --nginx -m admin@#{host.hostname} --non-interactive --agree-tos --domains #{host.hostname}
        EOBLOCK
      end
    end
  end

  task :ssl do
    on roles(:web, :api) do |_host|
      execute <<-EOBLOCK
        cd /etc/ssl/certs
        openssl dhparam -dsaparam -out dhparam.pem 2048
      EOBLOCK
      template "vhost_ssl.conf", "/etc/nginx/conf.d/vhost.conf"
      invoke "nginx:restart"
    end
  end

  %w[start stop restart status].each do |action|
    desc "Nginx"
    task :"#{action}" do
      on roles(:web, :api) do
        execute "sudo service nginx #{action}"
      end
    end
  end
end
