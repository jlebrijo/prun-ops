desc 'SSH connection with server'
task :ssh do
  on roles(:app) do |host|
    run_locally do
      run_in host, ""
    end
  end
end

desc 'Opens a remote Rails console'
task :c do
  on roles(:app) do |host|
    run_locally do
      run_in host, "cd #{current_path} && RAILS_ENV=#{fetch(:stage)} bundle exec rails c"
    end
  end
end

desc 'Opens a remote Database console'
task :dbconsole do
  on roles(:app) do |host|
    run_locally do
      run_in host, "cd #{current_path} && RAILS_ENV=#{fetch(:stage)} bundle exec rails dbconsole --include-password"
    end
  end
end

desc 'Tails the environment log or the log passed as argument: cap log_tail[thin.3000.log]'
task :log_tail, :file do |task, args|
  on roles(:app) do
    file = args[:file]? args[:file] : "*"
    execute "tail -f #{shared_path}/log/#{file} | grep -vE \"(^\s*$|asset|Render)\""
  end
end

desc 'Search for a pattern in logs'
task :log_pattern, :pattern do |task, args|
  on roles(:app) do
    execute "cat #{shared_path}/log/* | grep -A 10 -B 5 '#{args[:pattern]}'"
  end
end

desc "Runs a command in server: cap production x['free -m']"
task :x, :command do |task, args|
  on roles(:app) do |host|
    run_locally do
      run_in host, args[:command]
    end
  end
end

desc 'Executes a rake task in server. i.e.: cap staging rake[db:version]'
task :rake, :remote_task do |task, args|
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:stage) do
        execute :rake, "#{args[:remote_task]}"
      end
    end
  end
end


def run_in(host, cmd)
  exec "ssh #{host.user}@#{host.hostname} -p #{host.port || '22'} -tt '#{cmd}'"
end