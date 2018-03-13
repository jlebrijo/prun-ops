namespace :mysql do
  task :install do
    on roles :db do
      not_if 'which mysql' do
        execute <<-EOBLOCK
          debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{fetch :my_pass}'
          debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{fetch :my_pass}'
          apt-get install -y mysql-server mysql-client libmysqlclient-dev
        EOBLOCK
      end

      not_if "mysql --user='root' --password='#{fetch :my_pass}' --execute='show databases;' | grep #{fetch :application}" do
        execute <<-EOBLOCK
          mysql --user='root' --password='#{fetch :my_pass}' --execute='create database #{fetch :application};'
          mysql --user='root' --password='#{fetch :my_pass}' --execute="grant all on #{fetch :application}.* to #{fetch :my_user}@'%' identified by '#{fetch :my_pass}';"
        EOBLOCK
      end

      invoke 'mysql:restart'
    end
  end


  task :test do
    on roles :db do
      not_if "echo ''" do
        p 'executing ......'
      end
    end
  end


  %w(start stop restart).each do |action|
    desc "MySQL"
    task :"#{action}" do
      on roles(:app) do
        execute "sudo service mysql #{action}"
      end
    end
  end
end

def not_if(command)
  begin
     yield unless execute command
  rescue Exception
    yield
  end
end
