namespace :nginx do
  task :install do
    on roles :web do
      execute 'sudo apt-get install -y nginx'
      execute 'sed -i "s/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 64/" /etc/nginx/nginx.conf'
      template 'vhost.conf', '/etc/nginx/conf.d/vhost.conf'

      invoke 'nginx:restart'
    end
  end

  task :cert do
    on roles(:web) do |host|
      run_locally do
        run_in host, <<-EOBLOCK
          cd /usr/local/sbin
          sudo wget https://dl.eff.org/certbot-auto
          sudo chmod a+x /usr/local/sbin/certbot-auto
          mkdir /var/www/#{fetch :application}/current/public/.well-known
          sudo certbot-auto certonly -a webroot --webroot-path=/var/www/#{fetch :application}/current/public -d #{host.hostname}
          sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
        EOBLOCK
      end
    end
  end

  task :ssl do
    on roles(:web) do |host|
      template 'vhost_ssl.conf', '/etc/nginx/conf.d/vhost.conf'
      invoke 'nginx:restart'
    end
  end

  %w(start stop restart status).each do |action|
    desc "Nginx"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service nginx #{action}"
      end
    end
  end
end
