namespace :nginx do
  task :install do
    on roles :web, :api do
      execute "#{apt_nointeractive} nginx"
      execute 'sudo sed -i "s/# server_names_hash_bucket_size 64/server_names_hash_bucket_size 64/" /etc/nginx/nginx.conf'
      template 'vhost.conf', '/etc/nginx/conf.d/vhost.conf'

      invoke 'nginx:restart'
    end
  end

  task :cert do
    on roles(:web, :api) do |host|
      run_locally do
        run_in host, <<-EOBLOCK
          sudo snap install --classic certbot
          sudo ln -s /snap/bin/certbot /usr/bin/certbot
          sudo certbot --nginx -m admin@#{host.hostname} --non-interactive --agree-tos --domains #{host.hostname}
        EOBLOCK
      end
    end
  end

  task :ssl do
    on roles(:web, :api) do |host|
      template 'vhost_ssl.conf', '/etc/nginx/conf.d/vhost.conf'
      invoke 'nginx:restart'
    end
  end

  %w(start stop restart status).each do |action|
    desc "Nginx"
    task :"#{action}" do
      on roles(:web, :api) do
        execute "sudo service nginx #{action}"
      end
    end
  end
end
